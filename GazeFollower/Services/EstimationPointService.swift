//
//  EstimationPointService.swift
//  GazeFollower
//
//  Created by Paweł Lelental on 06/03/2021.
//

import Foundation
import ARKit

class EstimationPointService {
    
    private let pointRendererHelper = PointRendererHelper()
    private let scnVectorHelper = SCNVectorHelper()
    private var numberOfPathPoints = 25
    
    
    func get(face: FaceGeometryNode?,  fakeNode: SCNNode, faceAnchor: ARFaceAnchor) -> CGPoint{
        
        let options : [String: Any] = [SCNHitTestOption.backFaceCulling.rawValue: false,
                                       SCNHitTestOption.searchMode.rawValue: 1,
                                       SCNHitTestOption.ignoreChildNodes.rawValue : false,
                                       SCNHitTestOption.ignoreHiddenNodes.rawValue : false]
        
        let testL = fakeNode.hitTestWithSegment(
            from: fakeNode.convertPosition(face!.leftEye.worldPosition, from:nil),
            to:  fakeNode.convertPosition(face!.leftEyeEnd.worldPosition, from:nil),
            options: options)
        
        let testR = fakeNode.hitTestWithSegment(
            from: fakeNode.convertPosition(face!.rightEye.worldPosition, from:nil),
            to:  fakeNode.convertPosition(face!.rightEyeEnd.worldPosition, from:nil),
            options: options)
        
        if (testL.count > 0 && testR.count > 0) {
            let r = getEyesGazeOnTheScreen(leftEye: testL[0].localCoordinates, rightEye: testR[0].localCoordinates, faceAnchor: faceAnchor)
            return r
            
        }
        return CGPoint(x: 0, y: 0)
    }
    
    var positions: Array<simd_float2> = Array()
    var positions2: Array<simd_float2> = Array()
    
    func getEyesGazeOnTheScreen(eyes: SCNVector3, faceAnchor: ARFaceAnchor) -> CGPoint{
        
        positions2.append(simd_float2(eyes.x,eyes.y));
        if positions2.count > 20 {
            positions2.removeFirst()
        }
        
        var total = simd_float2(0,0);
        for pos in positions2 {
            total.x += pos.x
            total.y += pos.y
        }
        
        total.x /= Float(positions2.count)
        total.y /= Float(positions2.count)
        
        return CGPoint(x: CGFloat(total.x), y: CGFloat(total.y))
    }
    
    func getEyesGazeOnTheScreen(leftEye: SCNVector3, rightEye: SCNVector3, faceAnchor: ARFaceAnchor) -> CGPoint{
        let height = Float(UIScreen.main.bounds.height)
        let width = Float(UIScreen.main.bounds.width)
        let iPhoneXMeterSize = simd_float2(0.0757, 0.1509)
        
        let countedX = ((leftEye.x + rightEye.x) / 2)
        let countedY =  (-((leftEye.y + rightEye.y) / 2))
        var x =  countedX / (iPhoneXMeterSize.x / 2.0) * width
        var y = countedY / (iPhoneXMeterSize.y / 2.0) *  height + 312
        
        x = Float.maximum(Float.minimum(x, width - 1), 0)
        y = Float.maximum(Float.minimum(y, height - 1), 0)
        
        positions.append(simd_float2(x,y));
        if positions.count > 20 {
            positions.removeFirst()
        }
        
        var total = simd_float2(0,0);
        for pos in positions {
            total.x += pos.x
            total.y += pos.y
        }
        
        total.x /= Float(positions.count)
        total.y /= Float(positions.count)
        
        return CGPoint(x: CGFloat(total.x), y: CGFloat(total.y))
    }
    
}

