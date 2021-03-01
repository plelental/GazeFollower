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

class GazePointController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet weak var gazeView: ARSCNView!

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for faceAnchor: ARAnchor) {
        guard #available(iOS 12.0, *), let faceAnchor = faceAnchor as? ARFaceAnchor
                else {
            return
        }

        let faceAnchorNode = SCNVector3(faceAnchor.lookAtPoint.x, faceAnchor.lookAtPoint.y, faceAnchor.lookAtPoint.z)
        let v2p = gazeView.projectPoint(faceAnchorNode)
        let cgp = CGPoint(x: CGFloat(v2p.x), y: CGFloat(v2p.y))
        let dotPath = UIBezierPath(ovalIn: CGRect(x: cgp.x, y: cgp.y, width: 15, height: 15))

        let layer = CAShapeLayer()
        layer.path = dotPath.cgPath
        layer.strokeColor = UIColor.red.cgColor
        gazeView.layer.addSublayer(layer)

        if gazeView.layer.sublayers!.count > 25 {
            gazeView.layer.sublayers?.removeFirst(24)
        }
    }
}
