//
//  DeviceModel.swift
//  GazeFollower
//
//  Created by Paweł Lelental on 13/03/2021.
//

import Foundation
import ARKit

class DeviceModel {

    public var screenHeight: Float = Float(UIScreen.main.bounds.height)
    public var screenWidth: Float = Float(UIScreen.main.bounds.width)
    public var deviceHeight: Float = 0
    public var deviceWidth: Float = 0
    public var screenNode: SCNNode = SCNNode()

    init() {
        deviceWidth = getDeviceSize().width
        deviceHeight = getDeviceSize().height
    }

    public func setUpDeviceScreenNode(view: ARSCNView) {
        screenNode.geometry?.firstMaterial?.isDoubleSided = true

        let virtualScreenNode: SCNNode = {
            let screenGeometry = SCNPlane(width: 1, height: 1)
            screenGeometry.firstMaterial?.isDoubleSided = true
            return SCNNode(geometry: screenGeometry)
        }()

        screenNode.addChildNode(virtualScreenNode)
        view.scene.rootNode.addChildNode(screenNode)
    }

    private func getDeviceSize() -> (width: Float, height: Float) {
        switch UIDevice.modelName {
        case "iPhone 11":
            return (width: 0.0757, height: 0.1509)
        case "iPhone X":
            return (width: 0.0709, height: 0.1436)
        case "iPhone XS":
            return (width: 0.0709, height: 0.1436)
        case "iPhone XS Max":
            return (width: 0.0774, height: 0.1575)
        case "iPhone XR":
            return (width: 0.0757, height: 0.1509)
        case "iPhone 11 Pro":
            return (width: 0.0714, height: 0.1440)
        case "iPhone 11 Pro Max":
            return (width: 0.0778, height: 0.1580)
        case "iPhone 12 mini":
            return (width: 0.0642, height: 0.1315)
        case "iPhone 12":
            return (width: 0.0715, height: 0.1467)
        case "iPhone 12 Pro":
            return (width: 0.0715, height: 0.1467)
        case "iPhone 12 Pro Max":
            return (width: 0.0781, height: 0.1608)
        default:
            return (width: 0, height: 0)
        }
    }
}
