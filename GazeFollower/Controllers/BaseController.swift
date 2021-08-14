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

    func renderScreenPoint(width: Int, height: Int, subViewToRender: UIView, arView: ARSCNView) {
        let screenPoint = ScreenPointModel(cornerRadius: 20,
                shadowOpacity: 1,
                shadowOffset: .zero,
                shadowRadius: 20,
                shadowPath: UIBezierPath(rect: subViewToRender.bounds).cgPath,
                width: width,
                height: height,
                x: 0,
                y: 0,
                backgroundColor: ColorHelper.UIColorFromRGB(0x1273DE))

        setUpAndRenderPointOnTheScreen(uiView: subViewToRender, arView: arView, screenPoint: screenPoint)
    }

    func renderScreenPointWithColor(width: Int, height: Int, subViewToRender: UIView, arView: ARSCNView, color: UIColor) {
        let screenPoint = ScreenPointModel(cornerRadius: 20,
                shadowOpacity: 1,
                shadowOffset: .zero,
                shadowRadius: 20,
                shadowPath: UIBezierPath(rect: subViewToRender.bounds).cgPath,
                width: width,
                height: height,
                x: 0,
                y: 0,
                backgroundColor: color)

        setUpAndRenderPointOnTheScreen(uiView: subViewToRender, arView: arView, screenPoint: screenPoint)
    }

    func renderScreenPointWithColor(width: Int, height: Int, subViewToRender: UIView, arView: ARSCNView, rgbColor: Int) {
        let screenPoint = ScreenPointModel(cornerRadius: 20,
                shadowOpacity: 1,
                shadowOffset: .zero,
                shadowRadius: 20,
                shadowPath: UIBezierPath(rect: subViewToRender.bounds).cgPath,
                width: width,
                height: height,
                x: 0,
                y: 0,
                backgroundColor: ColorHelper.UIColorFromRGB(rgbColor))

        setUpAndRenderPointOnTheScreen(uiView: subViewToRender, arView: arView, screenPoint: screenPoint)
    }

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
        view.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
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
