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

class WebBrowserController: BaseController, ARSCNViewDelegate, ARSessionDelegate, UIWebViewDelegate {

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

    }

    override func viewDidAppear(_ animated: Bool) {
        setUpNavigationBarAfterAppear(hidden: false, animated: animated)
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

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for faceAnchor: ARAnchor) {
        guard #available(iOS 12.0, *), let faceAnchor = faceAnchor as? ARFaceAnchor
                else {
            return
        }

        faceModel.update(faceAnchor: faceAnchor, view: arView, node: node)

        guard let mouthPucker = faceAnchor.blendShapes[.mouthPucker] else {
            return
        }

        DispatchQueue.main.async(execute: { () -> Void in
            let point = self.faceModel.estimationPointOnTheScreen
            self.gazePoint.center = point
            if mouthPucker.floatValue > 0.5 {
                self.webView.stringByEvaluatingJavaScript(from: "document.elementFromPoint(\(point.x),\(point.y - 50)).click()")
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
