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
    private let estimationPointService = EstimationPointService()


    override func viewDidLoad() {
        super.viewDidLoad()
        SetupSceneView()
    }

    override func viewDidAppear(_ animated: Bool) {
        setUpNavigationBarAfterAppear(hidden: false, animated: animated)
    }

    override func viewWillAppear(_ animated: Bool) {
        initNavigationBar()

        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        configuration.isWorldTrackingEnabled = true
        configuration.worldAlignment = ARConfiguration.WorldAlignment.camera

        gazeView.scene.background.contents = UIColor.white
        gazeView.session.run(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.hideNavigationBar()
        gazeView.session.pause()
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for faceAnchor: ARAnchor) {
        guard #available(iOS 12.0, *), let faceAnchor = faceAnchor as? ARFaceAnchor
                else {
            return
        }
        let cords = estimationPointService.getEstimationPointCoordinates(faceAnchor: faceAnchor, view: gazeView)
        estimationPointService.renderEstimationPoints(cgp: cords,view: gazeView)
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
}
