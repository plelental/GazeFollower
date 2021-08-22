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

class ReadingController: SessionRecordingBaseController {

    @IBOutlet weak var gazeView: ARSCNView!
    @IBOutlet weak var textToRead: UILabel!

    private let scnVectorHelper = SCNVectorHelper()
    private var faceModel: FaceModel!
    private var gazePointView: UIView = UIView()


    override func viewDidLoad() {
        super.viewDidLoad()
        setUpARSCNView(view: gazeView, viewDelegate: self, arSessionDelegate: self)
        faceModel = FaceModel(view: gazeView)
        textToRead.text = ReadingTextConstants.readingText
        listenVolumeButton()
    }

    func listenVolumeButton() {
        do {
            try audioSession.setActive(true)
        } catch {

        }

        outputVolumeObserve = audioSession.observe(\.outputVolume) { (audioSession, changes) in
            if (self.isRecordingSession) {
                self.isRecordingSession = false
                self.GenerateTrackingRoute(arView: self.gazeView)
                self.screenShot = UIApplication.shared.getScreenshot()!
                try! self.DataToJson(jsonFileName: Constants.readingFileNameJson)
                self.ShowAlert(title: "The recording session has ended",
                        message: "To save data confirm sending of a mail",
                        handler: { _ in
                            self.sendEmail(screenShot: self.screenShot, fileNameJson: Constants.readingFileNameJson, fileNameJpeg: Constants.readingFileNameJpeg)
                        })
            }
        }
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
                self.distancesFromDevice.append(Int(self.faceModel.distanceFromDevice()))
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
}
