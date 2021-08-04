//
//  CalibrationController.swift
//  GazeFollower
//
//  Created by Paweł Lelental on 06/03/2021.
//

import Foundation
import ARKit

@available(*, deprecated)
class CalibrationController: BaseController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet weak var calibrationView: ARSCNView!
    @IBOutlet weak var counterOfSteps: UILabel!

    private var isScreenTouched = false;
    private var gazePoint: UIView = UIView()
    private var calibrationPoint: UIView = UIView()
    private var faceModel: FaceModel!
    private var calibrationPointModel = CalibrationPointModel()
    private var calibrationDataPointService = CalibrationDataPointService()
    private var isDepthDataCaptured = false
    private var arFrame: ARFrame?
    private var startTimeOfCalibration: DispatchTime?
    private var counter: Int = 0
    private var distance: Float = 0
    private var canProcess = true

    @objc func touchedScreen(touch: UITapGestureRecognizer) {
        isScreenTouched = true;
        counter += 1
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpARSession(view: calibrationView)
        setUpARSCNView(view: calibrationView, viewDelegate: self, arSessionDelegate: self)
        faceModel = FaceModel(view: calibrationView)
        calibrationView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.touchedScreen(touch:))))
    }

    override func viewDidAppear(_ animated: Bool) {
        setUpNavigationBarAfterAppear(hidden: false, animated: animated)
        renderScreenPoints()
        startTimeOfCalibration = DispatchTime.now()
        UIApplication.shared.isIdleTimerDisabled = true
    }

    override func viewWillAppear(_ animated: Bool) {
        initNavigationBar()
        calibrationView.scene.background.contents = UIColor.white
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

        faceModel.update(faceAnchor: faceAnchor, view: calibrationView, node: node)

        DispatchQueue.main.async(execute: { () -> Void in
            self.gazePoint.center = self.faceModel.estimationPointOnTheScreen
            self.calibrationPoint.center = self.calibrationPointModel.point
            self.distance = self.faceModel.distanceFromDevice()
            self.counterOfSteps.text = "Step: " + String(self.counter) + " Distance: " + String(self.distance) + "cm"

            guard let mouthPucker = faceAnchor.blendShapes[.mouthPucker] else {
                return
            }

            if self.canProcess && self.isDepthDataCaptured {
                if mouthPucker.floatValue > 0.5 {
                    self.canProcess = false
                    self.counter += 1
                    self.saveData()
                }

            } else {
                if mouthPucker.floatValue < 0.4 {
                    self.canProcess = true
                }
            }

            if self.isScreenTouched && self.isDepthDataCaptured {
                self.isScreenTouched = false
                self.saveData()
            }
        })
    }

    private func saveData() {
        let endTimeOfCalibration = DispatchTime.now()
        let elapsedTime = endTimeOfCalibration.uptimeNanoseconds - self.startTimeOfCalibration!.uptimeNanoseconds

        self.calibrationDataPointService.saveCalibrateDataPoint(
                calibrationPoint: self.calibrationPointModel.point,
                estimationPoint: self.gazePoint.center,
                distance: self.faceModel.distanceFromDevice(),
                arFrame: self.arFrame!,
                calibrationStep: self.calibrationPointModel.calibrationStep ?? CalibrationStepEnum.OutOfTheScreen,
                elapsedTime: elapsedTime)

        self.calibrationPointModel.update()
        self.startTimeOfCalibration = DispatchTime.now()
    }

    private func renderScreenPoints() {

        let screenGazePoint = ScreenPointModel(
                cornerRadius: 20,
                shadowOpacity: 1,
                shadowOffset: .zero,
                shadowRadius: 20,
                shadowPath: UIBezierPath(rect: gazePoint.bounds).cgPath,
                width: 40,
                height: 40,
                x: 0,
                y: 0,
                backgroundColor: ColorHelper.UIColorFromRGB(0x1273DE))

        let screenCalibrationPoint = ScreenPointModel(
                cornerRadius: 25,
                width: 50,
                height: 50,
                x: 0,
                y: 100,
                backgroundColor: UIColor.red)

        setUpAndRenderPointOnTheScreen(uiView: gazePoint, arView: calibrationView, screenPoint: screenGazePoint)
        setUpAndRenderPointOnTheScreen(uiView: calibrationPoint, arView: calibrationView, screenPoint: screenCalibrationPoint)
    }

    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
    }

    func session(_ session: ARSession, didUpdate frame: ARFrame) {

        if (frame.capturedDepthData != nil) {
            arFrame = frame
            isDepthDataCaptured = true

        } else {
            isDepthDataCaptured = false
        }
    }
}
