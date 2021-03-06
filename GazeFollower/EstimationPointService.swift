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

    
    func getEstimationPointCoordinates(faceAnchor: ARFaceAnchor, view: ARSCNView!) -> CGPoint{
        let lookAtPointSCNVector = scnVectorHelper.createSCNVectorFromSimdFloat3(simdFloats3: faceAnchor.lookAtPoint)
        //        let rightEye = createSCNVectorFromSimdFloat4(simdFloats4: faceAnchor.rightEyeTransform.columns.3)
        //        let leftEye = createSCNVectorFromSimdFloat4(simdFloats4: faceAnchor.leftEyeTransform.columns.3)

        //        let rightAnchorsColumns = faceAnchor.rightEyeTransform.columns
        //        let leftAnchorsColumns = faceAnchor.leftEyeTransform.columns
        let gazeProjectedPoint = view.projectPoint(lookAtPointSCNVector)
        //        let eye = gazeView.projectPoint(createSCNVectorFromSimdFloat3FromTwo(firstSimdFloats3: faceAnchor.rightEyeTransform.columns.3, secondSimdFloats3: faceAnchor.leftEyeTransform.columns.3))
        //        let leftEyePoint = gazeView.projectPoint(leftEye)
        //        let rightEyePoint = gazeView.projectPoint(rightEye)
        //
        //        let xPoint = (leftEyePoint.x + rightEyePoint.x) / 2
        //        let yPoint = (leftEyePoint.y + rightEyePoint.y) / 2
        let points = pointRendererHelper.smoothRenderingOfTheProjectedPoints(pointX: gazeProjectedPoint.x, pointY: gazeProjectedPoint.y)
        //        let points = smoothRenderingOfTheProjectedPoints(pointX: xPoint ,pointY:yPoint)
        return CGPoint(x: CGFloat(points.x), y: CGFloat(points.y))
      
    }
    
    func renderEstimationPoints(cgp: CGPoint, view: ARSCNView!){
        let pointsPath = UIBezierPath(ovalIn: CGRect(x: cgp.x, y: cgp.y, width: 45, height: 45))

        let layer = CAShapeLayer()
        layer.path = pointsPath.cgPath
        layer.strokeColor = UIColor.red.cgColor

        DispatchQueue.main.async(execute: { () -> Void in
            view.layer.addSublayer(layer)
            if view.layer.sublayers!.count > self.numberOfPathPoints {
                let countOfViews = view.layer.sublayers?.count
                view.layer.sublayers?.removeFirst((countOfViews ?? 1) - 1)
            }
        })
    }
}
