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
    var positions: Array<simd_float2> = Array()
    var numberOfPathPoints = 25
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SetupSceneView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.setUpNavigationBarAfterAppear(hidden: false, animated: animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.initNavigationBar()
        
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        configuration.isWorldTrackingEnabled = true
        configuration.worldAlignment = ARConfiguration.WorldAlignment.camera
        
        gazeView.scene.background.contents = UIColor.white
        gazeView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.hideNavigatonBar()
        gazeView.session.pause()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for faceAnchor: ARAnchor) {
        guard #available(iOS 12.0, *), let faceAnchor = faceAnchor as? ARFaceAnchor
        else {
            return
        }
        
        let lookAtPointSCNVector = createSCNVectorFromSimdFloat3(simdFloats3: faceAnchor.lookAtPoint)
        //        let rightEye = createSCNVectorFromSimdFloat4(simdFloats4: faceAnchor.rightEyeTransform.columns.3)
        //        let leftEye = createSCNVectorFromSimdFloat4(simdFloats4: faceAnchor.leftEyeTransform.columns.3)
        
        //        let rightAnchorsColumns = faceAnchor.rightEyeTransform.columns
        //        let leftAnchorsColumns = faceAnchor.leftEyeTransform.columns
        let gazeProjectedPoint = gazeView.projectPoint(lookAtPointSCNVector)
        //        let eye = gazeView.projectPoint(createSCNVectorFromSimdFloat3FromTwo(firstSimdFloats3: faceAnchor.rightEyeTransform.columns.3, secondSimdFloats3: faceAnchor.leftEyeTransform.columns.3))
        //        let leftEyePoint = gazeView.projectPoint(leftEye)
        //        let rightEyePoint = gazeView.projectPoint(rightEye)
        //
        //        let xPoint = (leftEyePoint.x + rightEyePoint.x) / 2
        //        let yPoint = (leftEyePoint.y + rightEyePoint.y) / 2
        let points = smoothRenderingOfTheProjectedPoints(pointX: gazeProjectedPoint.x  ,pointY: gazeProjectedPoint.y )
        //        let points = smoothRenderingOfTheProjectedPoints(pointX: xPoint ,pointY:yPoint)
        let cgp = CGPoint(x: CGFloat(points.x), y: CGFloat(points.y))
        let pointsPath = UIBezierPath(ovalIn: CGRect(x: cgp.x, y: cgp.y, width: 45, height: 45))
        
        let layer = CAShapeLayer()
        layer.path = pointsPath.cgPath
        layer.strokeColor = UIColor.red.cgColor
        
        DispatchQueue.main.async(execute: {() -> Void in
            self.gazeView.layer.addSublayer(layer)
            if self.gazeView.layer.sublayers!.count > self.numberOfPathPoints {
                let countOfViews = self.gazeView.layer.sublayers?.count
                self.gazeView.layer.sublayers?.removeFirst( (countOfViews ?? 1) - 1)
            }
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
    
    func createSCNVectorFromSimdFloat3(simdFloats3: simd_float3) -> SCNVector3{
        return SCNVector3(simdFloats3.x, simdFloats3.y, simdFloats3.z)
    }
    
    func createSCNVectorFromSimdFloat4(simdFloats4: simd_float4) -> SCNVector3{
        return SCNVector3(simdFloats4.x, simdFloats4.y, simdFloats4.z)
    }
    
    func createSCNVectorFromSimdFloat3FromTwo(firstSimdFloats3: simd_float4, secondSimdFloats3: simd_float4) -> SCNVector3{
        let x = (firstSimdFloats3.x + secondSimdFloats3.x) / 2
        let y = (firstSimdFloats3.y + secondSimdFloats3.y) / 2
        let z = (firstSimdFloats3.z + secondSimdFloats3.z) / 2
        return SCNVector3(x, y, z)
    }
    
    func smoothRenderingOfTheProjectedPoints(pointX: Float, pointY: Float) -> simd_float2 {
        
        positions.append(simd_float2(pointX, pointY));
        
        if positions.count > 10 {
            positions.removeFirst()
        }
        
        var total = simd_float2(0,0);
        
        for pos in positions {
            total.x += pos.x
            total.y += pos.y
        }
        
        total.x /= Float(positions.count)
        total.y /= Float(positions.count)
        
        return total
    }
}
