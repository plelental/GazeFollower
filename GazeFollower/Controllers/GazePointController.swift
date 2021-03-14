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


class GazePointController: BaseController, ARSCNViewDelegate, ARSessionDelegate {
    
    @IBOutlet weak var gazeView: ARSCNView!
    
    private let scnVectorHelper = SCNVectorHelper()
    private var faceModel: FaceModel!
    private var gazePoint : UIView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpARSCNView(view: gazeView, viewDelegate: self, arSessionDelegate: self)
        faceModel = FaceModel(view: gazeView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setUpNavigationBarAfterAppear(hidden: false, animated: animated)
        renderScreenPoint()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initNavigationBar()
        setUpARSession(view: gazeView)
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
       
        DispatchQueue.main.async(execute: {() -> Void in
            self.gazePoint.center = self.faceModel.estimationPointOnTheScreen
        })
    }
    
    private func renderScreenPoint() {
        let screenPoint = ScreenPointModel(cornerRadius: 20,
                                           shadowOpacity: 1,
                                           shadowOffset: .zero,
                                           shadowRadius: 20,
                                           shadowPath: UIBezierPath(rect: gazePoint.bounds).cgPath,
                                           width: 40,
                                           height: 40,
                                           x: 0,
                                           y: 0,
                                           backgroundColor: ColorHelper.UIColorFromRGB(0x1273DE))
        
        setUpAndRenderPointOnTheScreen(uiView: gazePoint, arView: gazeView, screenPoint: screenPoint)
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
