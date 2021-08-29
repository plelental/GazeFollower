//
//  WebBrowserController.swift
//  GazeFollower
//
//  Created by Paweł Lelental on 04/08/2021.
//

import Foundation
import UIKit
import SceneKit
import ARKit
import WebKit

class WebBrowserController: SessionRecordingBaseController, UIWebViewDelegate {

    @IBOutlet weak var arView: ARSCNView!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet var mainView: UIView!

    private let scnVectorHelper = SCNVectorHelper()
    private var faceModel: FaceModel!
    private var gazePoint: UIView = UIView()


    override func viewDidLoad() {
        super.viewDidLoad()

        let url = URL(string: "https://www.pg.edu.pl");
        let request = URLRequest(url: url!);
        webView.loadRequest(request);

        setUpARSCNView(view: arView, viewDelegate: self, arSessionDelegate: self)
        faceModel = FaceModel(view: arView)
        listenVolumeButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        setUpNavigationBarAfterAppear(hidden: false, animated: animated)
        ShowAlert(title: "Recording session",
                message: """
                         The web browser session after clicking \"Ok\" button will be recorded. To stop recording tap twice on the screen. 
                         Attention: Scrolling of the page and clicking page elements using facial features will reset session!
                         """,
                handler: { _ in _ = self.isRecordingSession = true })
        renderScreenPoint(width: 30, height: 30, subViewToRender: gazePoint, arView: arView)
        mainView.insertSubview(gazePoint, at: 2)
    }

    override func viewWillAppear(_ animated: Bool) {
        initNavigationBar()
        setUpARSession(view: arView)
        arView.scene.background.contents = UIColor.white
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.hideNavigationBar()
        arView.session.pause()
    }


    func listenVolumeButton() {
        do {
            try audioSession.setActive(true)
        } catch {

        }

        outputVolumeObserve = audioSession.observe(\.outputVolume) { (audioSession, changes) in
            if (self.isRecordingSession) {
                self.isRecordingSession = false
                self.GenerateTrackingRoute(mainView: self.mainView)
                self.screenShot = UIApplication.shared.getScreenshot()!
                try! self.DataToJson(jsonFileName: Constants.webBrowserFileNameJson)
                self.ShowAlert(title: "The recording session has ended",
                        message: "To save data confirm sending of a mail",
                        handler: { _ in
                            self.sendEmail(screenShot: self.screenShot, fileNameJson: Constants.webBrowserFileNameJson, fileNameJpeg: Constants.webBrowserFileNameJpeg)
                        })
            }
        }
    }


    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for faceAnchor: ARAnchor) {
        guard #available(iOS 12.0, *), let faceAnchor = faceAnchor as? ARFaceAnchor
                else {
            return
        }

        faceModel.update(faceAnchor: faceAnchor, view: arView, node: node)

        guard let mouthPucker = faceAnchor.blendShapes[.mouthPucker] else {
            return
        }


        guard let jawLeft = faceAnchor.blendShapes[.jawLeft] else {
            return
        }

        guard let jawRight = faceAnchor.blendShapes[.jawRight] else {
            return
        }

        DispatchQueue.main.async(execute: { () -> Void in
            let point = self.faceModel.estimationPointOnTheScreen
            self.gazePoint.center = point

            if (self.isRecordingSession) {
                self.gazePointsList.append(self.GenerateCoords(point: point))
                self.distancesFromDevice.append(Int(self.faceModel.distanceFromDevice()))
            }

            if mouthPucker.floatValue > 0.5 {
                self.webView.stringByEvaluatingJavaScript(from: "document.elementFromPoint(\(point.x),\(point.y - 50)).click()")
                self.gazePointsList = []
            }
            if jawRight.floatValue > 0.2 {
                self.webView.stringByEvaluatingJavaScript(from: "window.scrollBy(0,\(10))")
                self.gazePointsList = []
            }
            if jawLeft.floatValue > 0.2 {
                self.webView.stringByEvaluatingJavaScript(from: "window.scrollBy(0,\(-10))")
                self.gazePointsList = []
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
