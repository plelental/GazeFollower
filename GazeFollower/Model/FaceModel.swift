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
    private var estimationPointsX: Array<Int> = Array()
    private var estimationPointsY: Array<Int> = Array()

    private var deviceModel: DeviceModel = DeviceModel()

    public var lookAtPoint: simd_float3 = simd_make_float3(0, 0, 0)
    public var estimationPointOnTheScreen: CGPoint = CGPoint()


    init(view: ARSCNView) {
        setUpEyes(view: view)
        deviceModel.setUpDeviceScreenNode(view: view)
    }

    func update(faceAnchor: ARFaceAnchor, view: ARSCNView, node: SCNNode) {
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
        let averageDistance = (leftEyeDistanceFromDevice + rightEyeDistanceFromDevice) / 2

        return round(averageDistance * 100)
    }

    private func setUpEyes(view: ARSCNView) {
        leftEye.opacity = 0
        rightEye.opacity = 0

        leftEye.eulerAngles.x = -.pi / 2
        leftEye.position.z = 0.1

        rightEye.eulerAngles.x = -.pi / 2
        rightEye.position.z = 0.1

        leftEye.addChildNode(getEyePositionChildNode())
        rightEye.addChildNode(getEyePositionChildNode())

        faceNode.addChildNode(leftEye)
        faceNode.addChildNode(rightEye)

        view.scene.rootNode.addChildNode(faceNode)
    }

    private func getEyePositionChildNode() -> SCNNode {
        let eyePositionNode = SCNNode()
        eyePositionNode.opacity = 0
        eyePositionNode.position.z = distanceFromDevice()
        return eyePositionNode
    }

    private func estimateEyesPositionOnDeviceScreen() -> CGPoint {
        let eyesCoordinates = estimateEyesCoordinates()
        let leftEye = eyesCoordinates.leftEyeCoordinates
        let rightEye = eyesCoordinates.rightEyeCoordinates

        if (leftEye == nil && rightEye == nil) {
            return CGPoint()
        }

        let lengthFromCameraToTheCenterOfScreenY = Float(deviceModel.screenHeight / 2)
        let eyesXCords = ((leftEye!.x + rightEye!.x) / 2)
        let eyesYCords = (-((leftEye!.y + rightEye!.y) / 2))

        let x = eyesXCords / (deviceModel.deviceWidth / 2.0) * deviceModel.screenWidth
        let y = eyesYCords / (deviceModel.deviceHeight / 2.0) * deviceModel.screenHeight + lengthFromCameraToTheCenterOfScreenY - 100

        if (estimationPointsX.count > (Int(distanceFromDevice() / 2))) {
            estimationPointsX.removeFirst()
            estimationPointsY.removeFirst()
        }
        estimationPointsX.append(Int(x))
        estimationPointsY.append(Int(y))
//        return CGPoint(x: CGFloat(x), y: CGFloat(y))
        return CGPoint(x: Mean(array: estimationPointsX), y: Mean(array: estimationPointsY))
//        return CGPoint(x: Median(array: estimationPointsX), y: Median(array: estimationPointsY))
    }


    private func Mean(array: [Int]) -> Int {
        array.reduce(0, +) / array.count
    }

    private func Median(array: [Int]) -> CGFloat {
        let sorted = array.sorted()
        let count = sorted.count
        if count % 2 == 0 {
            return CGFloat((sorted[(count / 2)] + sorted[(count / 2) - 1])) / 2
        } else {
            return CGFloat(sorted[(count - 1) / 2])
        }
    }

    private func estimateEyesCoordinates() -> (leftEyeCoordinates: SCNVector3?, rightEyeCoordinates: SCNVector3?) {
        let leftEyeHittingResult = getEyeHittingResults(deviceScreenNode: deviceModel.screenNode, eye: leftEye)
        let rightEyeHittingResult = getEyeHittingResults(deviceScreenNode: deviceModel.screenNode, eye: rightEye)

        if (!leftEyeHittingResult.isEmpty && !rightEyeHittingResult.isEmpty) {
            return (leftEyeCoordinates: leftEyeHittingResult.first?.localCoordinates,
                    rightEyeCoordinates: rightEyeHittingResult.first?.localCoordinates)
        }

        return (leftEyeCoordinates: nil, rightEyeCoordinates: nil)
    }

    private func getEyeHittingResults(deviceScreenNode: SCNNode, eye: SCNNode) -> Array<SCNHitTestResult> {
        deviceScreenNode.hitTestWithSegment(from: eye.childNodes[0].worldPosition, to: eye.worldPosition, options: nil)
    }
}
