//
//  GazePointController.swift
//  GazeFollower
//
//  Created by Paweł Lelental on 01/03/2021.
//

import Foundation
import UIKit
import SceneKit
import ARKit
import MessageUI

class ReadingController: BaseController, ARSCNViewDelegate, ARSessionDelegate, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var gazeView: ARSCNView!
    @IBOutlet weak var textToRead: UILabel!

    private let scnVectorHelper = SCNVectorHelper()
    private let fileService = FileService()
    private var faceModel: FaceModel!
    private var gazePointView: UIView = UIView()
    private var gazePointsList: [Coords] = []
    private var isRecordingSession = false
    private var screenShot: UIImage = UIImage()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpARSCNView(view: gazeView, viewDelegate: self, arSessionDelegate: self)
        faceModel = FaceModel(view: gazeView)
        textToRead.text = ReadingTextConstants.readingText
        DoubleTabListener()
    }

    override func viewDidAppear(_ animated: Bool) {
        setUpNavigationBarAfterAppear(hidden: false, animated: animated)
        ShowAlert(title: "Recording session",
                message: "The reading session after clicking \"Ok\" button will be recorded. To stop recording tap twice on the screen",
                handler: { _ in _ = self.isRecordingSession = true })

        renderScreenPoint(width: 30, height: 30, subViewToRender: gazePointView, arView: gazeView)
    }

    override func viewWillAppear(_ animated: Bool) {
        initNavigationBar()
        setUpARSession(view: gazeView)
        gazeView.scene.background.contents = UIColor.white
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.hideNavigationBar()
        gazeView.session.pause()
    }

    @objc func doubleTapped() {
        isRecordingSession = false
        GenerateTrackingRoute()
        screenShot = UIApplication.shared.getScreenshot()!
        try! DataToJson()
        ShowAlert(title: "The recording session has ended",
                message: "To save data confirm sending of a mail",
                handler: { _ in
                    self.sendEmail(screenShot: self.screenShot)
                })
    }

    func DataToJson() throws {
        guard let readingFile = fileService.getFileUrl(fileName: Constants.readingFileNameJson) else {
            return
        }
        let jsonEncoder = JSONEncoder()

        jsonEncoder.outputFormatting = .prettyPrinted

        let jsonData = try jsonEncoder.encode(gazePointsList)
        try? jsonData.write(to: readingFile, options: .atomicWrite)
    }

    func sendEmail(screenShot: UIImage) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["p.lelental@gmail.com"])
            guard let readingFile = fileService.getFileUrl(fileName: Constants.readingFileNameJson) else {
                return
            }
            do {
                let data = try Data(contentsOf: readingFile)
                mail.addAttachmentData(data as Data, mimeType: "application/json", fileName: Constants.readingFileNameJson)
                mail.addAttachmentData(screenShot.jpegData(compressionQuality: CGFloat(1.0))!, mimeType: "image/jpeg", fileName: Constants.readingFileNameJpeg)
            } catch let error {
                print("Encountered error \(error.localizedDescription)")
            }

            present(mail, animated: true)
        } else {
            print("Email cannot be sent")
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let _ = error {
            dismiss(animated: true, completion: nil)
        }
        switch result {
        case .cancelled:
            print("Cancelled")
            break
        case .sent:
            print("Mail sent successfully")
            break
        case .failed:
            print("Sending mail failed")
            break
        default:
            break
        }
        controller.dismiss(animated: true, completion: nil)
    }

    private func GenerateTrackingRoute() {
        for element in gazePointsList {
            let view = UIView()
            renderScreenPointWithColor(width: 30, height: 30, subViewToRender: view, arView: gazeView, color: ColorHelper.UIColorFromRGB(0xfe11f))
            view.center = CGPoint(x: element.x, y: element.y)
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for faceAnchor: ARAnchor) {
        guard #available(iOS 12.0, *), let faceAnchor = faceAnchor as? ARFaceAnchor
                else {
            return
        }

        faceModel.update(faceAnchor: faceAnchor, view: gazeView, node: node)

        DispatchQueue.main.async(execute: { () -> Void in
            let point = self.faceModel.estimationPointOnTheScreen
            self.gazePointView.center = point
            if (self.isRecordingSession) {
                self.gazePointsList.append(self.GenerateCoords(point: point))
            }
        })

    }

    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user

    }

    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay

    }

    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required

    }

    private func DoubleTabListener() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tap.numberOfTapsRequired = 2
        view.addGestureRecognizer(tap)
    }

    private func ShowAlert(title: String, message: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: handler))
        present(alert, animated: true)
    }

    private func GenerateCoords(point: CGPoint) -> Coords {
        Coords(x: Int(point.x), y: Int(point.y))
    }
}
