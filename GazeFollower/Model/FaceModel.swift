//
//  FaceModel.swift
//  GazeFollower
//
//  Created by Paweł Lelental on 13/03/2021.
//

import Foundation
import SceneKit
import ARKit

class FaceModel {
    
    private var leftEye: SCNNode = SCNNode()
    private var rightEye: SCNNode = SCNNode()
    private var faceNode: SCNNode = SCNNode()
    private var positions: Array<simd_float2> = Array()
    
    private var deviceModel: DeviceModel = DeviceModel()
    
    public var lookAtPoint: simd_float3 = simd_make_float3(0, 0, 0)
    public var estimationPointOnTheScreen: CGPoint = CGPoint()
    
    init(view: ARSCNView) {
        self.setUpEyes(view: view)
        deviceModel.setUpDeviceScreenNode(view: view)
    }
    
    func update(faceAnchor: ARFaceAnchor, view: ARSCNView, node : SCNNode) {
        faceNode.transform = node.transform
        leftEye.simdTransform = faceAnchor.leftEyeTransform
        rightEye.simdTransform = faceAnchor.rightEyeTransform
        deviceModel.screenNode.transform = (view.pointOfView?.transform)!
        lookAtPoint = faceAnchor.lookAtPoint
        estimationPointOnTheScreen = estimateEyesPositionOnDeviceScreen()
    }
    
    private func setUpEyes(view:ARSCNView) {
        leftEye.opacity = 0
        rightEye.opacity = 0
        leftEye.addChildNode(getEyePositionChildNode())
        rightEye.addChildNode(getEyePositionChildNode())
        faceNode.addChildNode(leftEye)
        faceNode.addChildNode(rightEye)
        view.scene.rootNode.addChildNode(faceNode)
    }
    
    private func getEyePositionChildNode() -> SCNNode {
        let eyePositionNode = SCNNode()
        eyePositionNode.position.z = 1
        return eyePositionNode
    }
    
    private func estimateEyesPositionOnDeviceScreen() -> CGPoint {
        let eyesCoordinates = estimateEyesCoordinates()
        let leftEye = eyesCoordinates.leftEyeCoordinates
        let rightEye = eyesCoordinates.rightEyeCoordinates
        
        if(leftEye == nil && rightEye == nil){
            return CGPoint()
        }
        
        let eyesXCords = ((leftEye!.x + rightEye!.x) / 2)
        let eyesYCords =  (-((leftEye!.y + rightEye!.y) / 2))
        let x =  eyesXCords / (deviceModel.deviceWidth / 2.0) * deviceModel.screenWidth
        let y = eyesYCords / (deviceModel.deviceHeight / 2.0) *  deviceModel.screenHeight + 312
        
        // Todo implement smoothing
        return CGPoint(x: CGFloat(x), y: CGFloat(y))
    }
    
    private func estimateEyesCoordinates() -> (leftEyeCoordinates: SCNVector3?, rightEyeCoordinates: SCNVector3?){
        let leftEyeHittingResult = getEyeHittingResults(deviceScreenNode: deviceModel.screenNode, eye: leftEye)
        let rightEyeHittingResult = getEyeHittingResults(deviceScreenNode: deviceModel.screenNode, eye: rightEye)
        
        if(!leftEyeHittingResult.isEmpty && !rightEyeHittingResult.isEmpty){
            return (leftEyeCoordinates: leftEyeHittingResult.first?.localCoordinates,
                    rightEyeCoordinates: rightEyeHittingResult.first?.localCoordinates)
        }
        
        return (leftEyeCoordinates: nil, rightEyeCoordinates: nil)
    }
    
    private func getEyeHittingResults(deviceScreenNode: SCNNode, eye: SCNNode) -> Array<SCNHitTestResult>{
        let eyeDevicePosition = deviceScreenNode.convertPosition(eye.worldPosition, to: nil)
        let eyeTargetDevicePosition = deviceScreenNode.convertPosition(eye.childNodes[0].worldPosition, to: nil)
        let eyeHittingTestResult = deviceScreenNode.hitTestWithSegment(from: eyeDevicePosition, to: eyeTargetDevicePosition)
        
        return eyeHittingTestResult
    }
}
