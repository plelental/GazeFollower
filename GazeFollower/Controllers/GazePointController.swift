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
    private var target : UIView = UIView()
    private var faceModel: FaceModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        SetupSceneView()
        faceModel = FaceModel(view: gazeView)
        
        target.backgroundColor = ColorHelper.UIColorFromRGB(0x1273DE)
        target.frame = CGRect.init(x: 0,y:0 ,width:40 ,height:40)
        target.layer.cornerRadius = 20
        target.layer.shadowOpacity = 1
        target.layer.shadowOffset = .zero
        target.layer.shadowRadius = 20
        target.layer.shadowPath = UIBezierPath(rect: target.bounds).cgPath

        gazeView.addSubview(target)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setUpNavigationBarAfterAppear(hidden: false, animated: animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initNavigationBar()
        
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        super.viewDidAppear(animated)
//        gazeView.scene.background.contents = UIColor.white
        gazeView.session.run(configuration)
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return .portrait }
    
    
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
            self.target.center = self.faceModel.estimationPointOnTheScreen
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
    
    private func SetupSceneView() {
        gazeView.delegate = self
        gazeView.session.delegate = self
        gazeView.scene = SCNScene()
        gazeView.automaticallyUpdatesLighting = true
        gazeView.autoenablesDefaultLighting = true
    }
}
