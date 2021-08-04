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

class WebBrowserController: BaseController, ARSCNViewDelegate, ARSessionDelegate{
    
    @IBOutlet weak var arView: ARSCNView!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet var mainView: UIView!
    
    private let scnVectorHelper = SCNVectorHelper()
    private var faceModel: FaceModel!
    private var gazePoint: UIView = UIView()


    override func viewDidLoad() {
        super.viewDidLoad()
       
        let url = URL (string: "https://www.pg.edu.pl");
        let request = URLRequest(url: url!);
        webView.loadRequest(request);
      
        setUpARSCNView(view: self.arView, viewDelegate: self, arSessionDelegate: self)
        faceModel = FaceModel(view: arView)

    }

    override func viewDidAppear(_ animated: Bool) {
        setUpNavigationBarAfterAppear(hidden: false, animated: animated)
        renderScreenPoint()
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

        DispatchQueue.main.async(execute: { () -> Void in
            self.gazePoint.center = self.faceModel.estimationPointOnTheScreen
        })

    }

    private func renderScreenPoint() {
        let screenPoint = ScreenPointModel(cornerRadius: 20,
                shadowOpacity: 1,
                shadowOffset: .zero,
                shadowRadius: 20,
                shadowPath: UIBezierPath(rect: gazePoint.bounds).cgPath,
                width: 20,
                height: 20,
                x: 0,
                y: 0,
                backgroundColor: ColorHelper.UIColorFromRGB(0x1273DE))

        gazePoint.frame = CGRect.init(
                x: screenPoint.x,
                y: screenPoint.y,
                width: screenPoint.width,
                height: screenPoint.height)

        gazePoint.backgroundColor = screenPoint.backgroundColor
        gazePoint.layer.cornerRadius = screenPoint.cornerRadius ?? 0

        if (screenPoint.withShadowing) {
            gazePoint.layer.shadowOpacity = screenPoint.shadowOpacity ?? 0.0
            gazePoint.layer.shadowOffset = screenPoint.shadowOffset ?? CGSize()
            gazePoint.layer.shadowRadius = screenPoint.shadowRadius ?? 3.0
            gazePoint.layer.shadowPath = screenPoint.shadowPath
        }
        mainView.insertSubview(gazePoint, at: 2)
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
