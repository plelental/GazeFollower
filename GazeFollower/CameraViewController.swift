//
//  CameraViewController.swift
//  GazeFollower
//
//  Created by Paweł Lelental on 30/01/2021.
//

import UIKit
import SceneKit
import ARKit

class CameraViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    
    @IBOutlet weak var leftEyeX: UITextField!
    @IBOutlet weak var leftEyeY: UITextField!
    @IBOutlet weak var leftEyeZ: UITextField!
    @IBOutlet weak var rightEyeY: UITextField!
    @IBOutlet weak var rightEyeX: UITextField!
    @IBOutlet weak var rightEyeZ: UITextField!
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    var contentNode: SCNNode?
    lazy var rightEyeNode = SCNReferenceNode(named: "coordinateOrigin")
    lazy var leftEyeNode = SCNReferenceNode(named: "coordinateOrigin")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.rightEyeZ.backgroundColor = .white
        self.rightEyeZ.textColor = .blue
        self.rightEyeZ.textAlignment = .center
        
        self.rightEyeX.backgroundColor = .white
        self.rightEyeX.textColor = .blue
        self.rightEyeX.textAlignment = .center
        
        self.rightEyeY.backgroundColor = .white
        self.rightEyeY.textColor = .blue
        self.rightEyeZ.textAlignment = .center
        
        self.leftEyeZ.backgroundColor = .white
        self.leftEyeZ.textColor = .blue
        self.leftEyeZ.textAlignment = .center
        
        self.leftEyeX.backgroundColor = .white
        self.leftEyeX.textColor = .blue
        self.leftEyeX.textAlignment = .center
        
        self.leftEyeY.backgroundColor = .white
        self.leftEyeY.textColor = .blue
        self.leftEyeY.textAlignment = .center
        
        sceneView.delegate = self
        sceneView.session.delegate = self
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.automaticallyUpdatesLighting = true
        sceneView.autoenablesDefaultLighting = true
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated:    animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        // Create a session configuration
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        // Run the view's session
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.isTranslucent = false
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - ARSCNViewDelegate
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    // MARK: - ARSCNViewDelegate -
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        // Check if face anchor
        if let faceAnchor = anchor as? ARFaceAnchor {
            
            // Create empty node
            contentNode = SCNReferenceNode(named: "coordinateOrigin")
            //            self.rightEyeX.text = String(faceAnchor.rightEyeTransform.columns.0)
            print("Left eye", faceAnchor.leftEyeTransform)
            print("Right eye", faceAnchor.rightEyeTransform)
            self.addEyeTransformNodes()
            
            // Return node
            return contentNode
        }
        
        // Don't know and don't care what kind of anchor this is so return empty node
        return SCNNode()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for faceAnchor: ARAnchor) {
        guard #available(iOS 12.0, *), let faceAnchor = faceAnchor as? ARFaceAnchor
        else { return }
        
        let rightEyePosition = SCNVector3(
            faceAnchor.rightEyeTransform.columns.3.x,
            faceAnchor.rightEyeTransform.columns.3.y,
            faceAnchor.rightEyeTransform.columns.3.z
        )
        
        let leftEyePosition = SCNVector3(
            faceAnchor.leftEyeTransform.columns.3.x,
            faceAnchor.leftEyeTransform.columns.3.y,
            faceAnchor.leftEyeTransform.columns.3.z
        )
     
        self.rightEyeX.text = "Right eye x: " + String(format: "%.5f",rightEyePosition.x)
        self.rightEyeY.text = "Right eye y: " + String(format: "%.5f",rightEyePosition.y)
        self.rightEyeZ.text = "Right eye z: " + String(format: "%.5f",rightEyePosition.z)
        
        self.leftEyeX.text = "Left eye x: " + String(format: "%.5f",leftEyePosition.x)
        self.leftEyeY.text = "Left eye y: " + String(format: "%.5f",leftEyePosition.y)
        self.leftEyeZ.text = "Left eye z: " + String(format: "%.5f",leftEyePosition.z)
        
        rightEyeNode.simdTransform = faceAnchor.rightEyeTransform
        leftEyeNode.simdTransform = faceAnchor.leftEyeTransform
    }
    
    func addEyeTransformNodes() {
        guard #available(iOS 12.0, *), let anchorNode = contentNode else { return }
        
        // Scale down the coordinate axis visualizations for eyes.
        rightEyeNode.simdPivot = float4x4(diagonal: float4(3, 3, 3, 1))
        leftEyeNode.simdPivot = float4x4(diagonal: float4(3, 3, 3, 1))
        
        anchorNode.addChildNode(rightEyeNode)
        anchorNode.addChildNode(leftEyeNode)
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
