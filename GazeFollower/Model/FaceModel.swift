//
//  FaceModel.swift
//  GazeFollower
//
//  Created by Paweł Lelental on 13/03/2021.
//

import Foundation
import ARKit

class FaceModel {
    
    private var leftEye: SCNNode = SCNNode()
    private var rightEye: SCNNode = SCNNode()
    private var faceNode: SCNNode = SCNNode()
    private var estimationPoints: Array<CGPoint> = Array()
    
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
    
    func distanceFromDevice() -> Float {
        let leftEyeDistanceFromDevice = (leftEye.worldPosition - SCNVector3Zero).length()
        let rightEyeDistanceFromDevice = (rightEye.worldPosition - SCNVector3Zero).length()
        let avarageDistance = (leftEyeDistanceFromDevice + rightEyeDistanceFromDevice) / 2
        return round(avarageDistance * 100)
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
        eyePositionNode.opacity = 0
        eyePositionNode.position.z = 2
        return eyePositionNode
    }
    
    private func estimateEyesPositionOnDeviceScreen() -> CGPoint {
        let eyesCoordinates = estimateEyesCoordinates()
        let leftEye = eyesCoordinates.leftEyeCoordinates
        let rightEye = eyesCoordinates.rightEyeCoordinates
        
        if(leftEye == nil && rightEye == nil){
            return CGPoint()
        }
        
        let lengthFromCameraToTheCenterOfScreenY = Float(deviceModel.screenHeight / 2)
        let eyesXCords = ((leftEye!.x + rightEye!.x) / 2)
        let eyesYCords =  (-((leftEye!.y + rightEye!.y) / 2))
        
        let x =  eyesXCords / (deviceModel.deviceWidth / 2.0) * deviceModel.screenWidth
        let y = eyesYCords / (deviceModel.deviceHeight / 2.0) *  deviceModel.screenHeight + lengthFromCameraToTheCenterOfScreenY
        let point = CGPoint(x: CGFloat(x), y: CGFloat(y))
        
        if(estimationPoints.count > (Int(distanceFromDevice() / 2))){
            estimationPoints.removeFirst()
        }
        estimationPoints.append(point)
        let averagePoint =  Array(estimationPoints).average!
        
        return averagePoint
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
      
        let options : [String: Any] = [SCNHitTestOption.backFaceCulling.rawValue: false,
                                       SCNHitTestOption.searchMode.rawValue: 1,
                                       SCNHitTestOption.ignoreLightArea.rawValue: true,
                                       SCNHitTestOption.boundingBoxOnly.rawValue: true,
                                       SCNHitTestOption.ignoreChildNodes.rawValue : false,
                                       SCNHitTestOption.ignoreHiddenNodes.rawValue : false]
        
        let eyeDevicePosition = deviceScreenNode.convertPosition(eye.worldPosition, to: nil)
        let eyeTargetDevicePosition = deviceScreenNode.convertPosition(eye.childNodes[0].worldPosition, to: nil)
        let eyeHittingTestResult = deviceScreenNode.hitTestWithSegment(from: eyeDevicePosition, to: eyeTargetDevicePosition,options: options)
        
        return eyeHittingTestResult
    }
}
