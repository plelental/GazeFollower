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
        deviceWidth = self.getDeviceSize().width

        deviceHeight = self.getDeviceSize().height
    }
    
    public func setUpDeviceScreenNode(view:ARSCNView){
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
        default:
            return (width: 0, height: 0)
        }
    }
}
