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
    @IBOutlet weak var lookingLeftRight: UITextField!
    @IBOutlet weak var lookingUpDown: UITextField!

    @IBOutlet weak var sceneView: ARSCNView!

    var contentNode: SCNNode?
    lazy var rightEyeNode = SCNReferenceNode(named: "coordinateOrigin")
    lazy var leftEyeNode = SCNReferenceNode(named: "coordinateOrigin")

    override func viewDidLoad() {
        super.viewDidLoad()
        SetEyeInformationBoxes()
        SetupSceneView()
    }

    private func SetupSceneView() {
        sceneView.delegate = self
        sceneView.session.delegate = self
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.automaticallyUpdatesLighting = true
        sceneView.autoenablesDefaultLighting = true
    }

    private func configureBoxesDisplayLayout(boxField: UITextField) {
        boxField.backgroundColor = .white
        boxField.textColor = .blue
        boxField.textAlignment = .center
    }

    private func SetEyeInformationBoxes() {
        configureBoxesDisplayLayout(boxField: rightEyeZ)
        configureBoxesDisplayLayout(boxField: rightEyeX)
        configureBoxesDisplayLayout(boxField: rightEyeY)
        configureBoxesDisplayLayout(boxField: leftEyeZ)
        configureBoxesDisplayLayout(boxField: leftEyeX)
        configureBoxesDisplayLayout(boxField: leftEyeY)
        configureBoxesDisplayLayout(boxField: lookingLeftRight)
        configureBoxesDisplayLayout(boxField: lookingUpDown)
    }

    override func viewDidAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true

        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.shadowImage = nil
        navigationController?.navigationBar.isTranslucent = false
        sceneView.session.pause()
    }

    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        if anchor is ARFaceAnchor {
            contentNode = SCNReferenceNode(named: "coordinateOrigin")
            addEyeTransformNodes()
            return contentNode
        }
        return SCNNode()
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for faceAnchor: ARAnchor) {
        guard #available(iOS 12.0, *), let faceAnchor = faceAnchor as? ARFaceAnchor
                else {
            return
        }

        setEyeBoxesContent(faceAnchor: faceAnchor)

        rightEyeNode.simdTransform = faceAnchor.rightEyeTransform
        leftEyeNode.simdTransform = faceAnchor.leftEyeTransform
    }
 
    private func setEyeBoxesContent(faceAnchor: ARFaceAnchor) {
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

        let horizontalLookPointText = faceAnchor.lookAtPoint.x > 0
                ? "You're looking on the right"
                : "You're looking on the left"

        let verticalLookPointText =
                faceAnchor.lookAtPoint.y > 0
                        ? "You're looking on the top"
                        : "You're looking on the bottom"

        lookingLeftRight.text = horizontalLookPointText
        lookingUpDown.text = verticalLookPointText
        
        rightEyeX.text = eyePositionText(eye: "Right", coordinate: "x", position: rightEyePosition.x)
        rightEyeY.text = eyePositionText(eye: "Right", coordinate: "y", position: rightEyePosition.y)
        rightEyeZ.text = eyePositionText(eye: "Right", coordinate: "z", position: rightEyePosition.z)

        leftEyeX.text = eyePositionText(eye: "Left", coordinate: "x", position: leftEyePosition.x)
        leftEyeY.text = eyePositionText(eye: "Left", coordinate: "y", position: leftEyePosition.y)
        leftEyeZ.text = eyePositionText(eye: "Left", coordinate: "z", position: leftEyePosition.z)
    }
    
    func eyePositionText(eye: String,coordinate: String, position: Float) -> String {
        return eye + " eye " + coordinate + ": " + String(format: "%.5f", position);
    }
    
    func addEyeTransformNodes() {
        guard #available(iOS 12.0, *), let anchorNode = contentNode else {
            return
        }

        rightEyeNode.simdPivot = float4x4(diagonal: SIMD4(3, 3, 3, 1))
        leftEyeNode.simdPivot = float4x4(diagonal: SIMD4(3, 3, 3, 1))
       
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
