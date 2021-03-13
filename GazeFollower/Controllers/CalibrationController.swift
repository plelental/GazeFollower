//
//  CalibrationController.swift
//  GazeFollower
//
//  Created by Paweł Lelental on 06/03/2021.
//

import Foundation
import ARKit

class CalibrationController: BaseController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet weak var calibrationView: ARSCNView!

    private let firstCalibrationStep = 1
    private let secondCalibrationStep = 2
    private let thirdCalibrationStep = 3
    private let fourthCalibrationStep = 4
    private let fifthCalibrationStep = 5

    private var isScreenTouched = false;
    private var step = 1
   
    private let fileService = FileService()

    private var cords = CGPoint()
   
    @objc func touchedScreen(touch: UITapGestureRecognizer) {
        isScreenTouched = true;
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        SetupSceneView()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.touchedScreen(touch:)))
        calibrationView.addGestureRecognizer(tap)
    }

    override func viewDidAppear(_ animated: Bool) {
        setUpNavigationBarAfterAppear(hidden: false, animated: animated)
    }

    override func viewWillAppear(_ animated: Bool) {
        initNavigationBar()

        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        configuration.isWorldTrackingEnabled = true
//        configuration.worldAlignment = ARConfiguration.WorldAlignment.camera
        
        calibrationView.scene.background.contents = UIColor.white
        calibrationView.session.run(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.hideNavigationBar()
        calibrationView.session.pause()
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for faceAnchor: ARAnchor) {
        guard #available(iOS 12.0, *), let faceAnchor = faceAnchor as? ARFaceAnchor
                else {
            return
        }
        renderPoint(step: step)
//        cords = estimationPointService.getEstimationPointCoordinates(faceAnchor: faceAnchor, view: calibrationView)
    }
   
    func renderPoint(step: Int) {
        DispatchQueue.main.async(execute: { () -> Void in
            self.calibrationView.layer.sublayers?.removeAll()
            let cords = self.getPointCoordinates(calibrationStep: step)
            let cgp = CGPoint(x: CGFloat(cords.x), y: CGFloat(cords.y))
            let pointsPath = UIBezierPath(ovalIn: CGRect(x: cgp.x, y: cgp.y, width: 45, height: 45))

            let layer = CAShapeLayer()
            layer.path = pointsPath.cgPath
            layer.strokeColor = UIColor.green.cgColor
            self.calibrationView.layer.addSublayer(layer)

            if self.isScreenTouched {
                self.isScreenTouched = false
                self.saveCalibrateDataPoint(calibrationPoint: cgp)
                self.step += 1
                if (self.step > 5) {
                    self.step = 1
                }
            }
        })
    }

    func saveCalibrateDataPoint(calibrationPoint: CGPoint) {

        guard let calibrationFile = fileService.getCalibrationFileUrl() else {
            return
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        let timestamp = formatter.string(from: Date())

        let text = "date: \(timestamp) | test_point_x: \(calibrationPoint.x) | test_point_y: \(calibrationPoint.y) | estimated_point_x: \(cords.x) | estimated_point_y: \(cords.y) \n"

        guard let data = (text).data(using: String.Encoding.utf8) else {
            return
        }

        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        if FileManager.default.fileExists(atPath: calibrationFile.path) {
            if let fileHandle = try? FileHandle(forWritingTo: calibrationFile) {
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            }
        } else {
            try? data.write(to: calibrationFile, options: .atomicWrite)
        }
    }

    func getPointCoordinates(calibrationStep: Int) -> (x: Float, y: Float) {
        let height = Float(UIScreen.main.bounds.height)
        let width = Float(UIScreen.main.bounds.width)

        switch calibrationStep {
        case firstCalibrationStep:
            return (x: 0, y: 100)
        case secondCalibrationStep:
            return (x: 0, y: height - 100)
        case thirdCalibrationStep:
            return (x: width - 50, y: height - 100)
        case fourthCalibrationStep:
            return (x: width - 50, y: 100)
        case fifthCalibrationStep:
            return (x: (width - 50) / 2, y: (height) / 2)
        default:
            return (-1, -1)
        }
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
        calibrationView.delegate = self
        calibrationView.session.delegate = self
        calibrationView.scene = SCNScene()
        calibrationView.automaticallyUpdatesLighting = true
        calibrationView.autoenablesDefaultLighting = true
    }
}
