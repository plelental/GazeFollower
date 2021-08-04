//
//  BaseController.swift
//  GazeFollower
//
//  Created by Paweł Lelental on 06/03/2021.
//

import Foundation
import UIKit
import ARKit

class BaseController: UIViewController {

    func setUpAndRenderPointOnTheScreen(uiView: UIView, arView: ARSCNView, screenPoint: ScreenPointModel) {

        uiView.frame = CGRect.init(
                x: screenPoint.x,
                y: screenPoint.y,
                width: screenPoint.width,
                height: screenPoint.height)

        uiView.backgroundColor = screenPoint.backgroundColor
        uiView.layer.cornerRadius = screenPoint.cornerRadius ?? 0

        if (screenPoint.withShadowing) {
            uiView.layer.shadowOpacity = screenPoint.shadowOpacity ?? 0.0
            uiView.layer.shadowOffset = screenPoint.shadowOffset ?? CGSize()
            uiView.layer.shadowRadius = screenPoint.shadowRadius ?? 3.0
            uiView.layer.shadowPath = screenPoint.shadowPath
        }

        arView.addSubview(uiView)
    }

    func setUpARSession(view: ARSCNView) {
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        configuration.maximumNumberOfTrackedFaces = 1
        view.session.run(configuration,options: [.resetTracking, .removeExistingAnchors])
    }

    func setUpARSCNView(view: ARSCNView, viewDelegate: ARSCNViewDelegate, arSessionDelegate: ARSessionDelegate) {
        view.delegate = viewDelegate
        view.session.delegate = arSessionDelegate
        view.scene = SCNScene()
        view.automaticallyUpdatesLighting = true
        view.autoenablesDefaultLighting = true
    }

    func initNavigationBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
    }

    func setUpNavigationBarAfterAppear(hidden: Bool, animated: Bool) {
        navigationController?.setNavigationBarHidden(hidden, animated: animated)
    }

    func hideNavigationBar() {
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.shadowImage = nil
        navigationController?.navigationBar.isTranslucent = false
    }
}
