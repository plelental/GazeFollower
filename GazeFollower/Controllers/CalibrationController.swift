//
//  CalibrationController.swift
//  GazeFollower
//
//  Created by Paweł Lelental on 06/03/2021.
//

import Foundation
import ARKit
import AVFoundation

class CalibrationController: BaseController, ARSCNViewDelegate, ARSessionDelegate {
    
    @IBOutlet weak var calibrationView: ARSCNView!
    
    private var isScreenTouched = false;
    private var gazePoint : UIView = UIView()
    private var calibrationPoint: UIView = UIView()
    private var faceModel: FaceModel!
    private var calibrationPointModel = CalibrationPointModel()
    private var calibrationDataPointService = CalibrationDataPointService()
    var photoSettings: AVCapturePhotoSettings!
    
    
    
    // Depth variables
    private let depthDataOutput = AVCaptureDepthDataOutput()
    private let session = AVCaptureSession()
    //    private let sessionQueue = DispatchQueue(label: "session queue", attributes: [], autoreleaseFrequency: .workItem)
    
    let photoOutput = AVCapturePhotoOutput()
    let captureProcessor = PhotoCaptureProcessor()
    
    //
    @objc func touchedScreen(touch: UITapGestureRecognizer) {
        isScreenTouched = true;
        calibrationView.session.pause()
        configureSession()
        photoSettings = AVCapturePhotoSettings.init(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        photoSettings.isAutoStillImageStabilizationEnabled = true
        let group = DispatchGroup()
        
        group.enter()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // Change `2.0` to the desired number of seconds.
            self.photoOutput.capturePhoto(with: self.photoSettings, delegate: self.captureProcessor)
            group.leave()
        }
        group.notify(queue: .main) {
            self.setUpARSession(view: self.calibrationView)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpARSCNView(view: calibrationView, viewDelegate: self, arSessionDelegate: self)
        faceModel = FaceModel(view: calibrationView)
        calibrationView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.touchedScreen(touch:))))
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setUpNavigationBarAfterAppear(hidden: false, animated: animated)
        renderScreenPoints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initNavigationBar()
        calibrationView.scene.background.contents = UIColor.white
        setUpARSession(view: calibrationView)
    }
    
    func configureSession(){
        // Select a depth-capable capture device.
        session.beginConfiguration()
        let deviceSession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera, .builtInTelephotoCamera, .builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified)
        for device in (deviceSession.devices){
            if device.position == AVCaptureDevice.Position.front {
                
                do{
                    let input = try AVCaptureDeviceInput(device: device)
                    if session.canAddInput(input) {
                        session.addInput(input)
                        
                        if session.canAddOutput(photoOutput) {
                            session.addOutput(photoOutput)
                        }
                        session.commitConfiguration()
                        session.startRunning()
                    }
                    
                }catch let avError {
                    print (avError)
                }
            }
        }
        //        }
        //        self.session.beginConfiguration()
        //
        //
        //        guard self.session.canAddOutput(photoOutput) else { return }
        //        self.session.sessionPreset = .photo
        //        //        self.session.addOutput(photoOutput)
        //        session.addOutput(photoOutput)
        //
        //
        //        self.session.commitConfiguration()
        //        self.session.startRunning()
        
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
            
            if self.isScreenTouched {
                self.isScreenTouched = false
                self.calibrationDataPointService.saveCalibrateDataPoint(
                    calibrationPoint: self.calibrationPointModel.point,
                    estimationPoint: self.gazePoint.center,
                    distance: 0,
                    calibrationStep: self.calibrationPointModel.calibrationStep ?? CalibrationStep.OutOfTheScreen)
                
                
                //                photoSettings.flashMode = .auto
                //                photoSettings.isAutoStillImageStabilizationEnabled =
                //                    self.photoOutput.isStillImageStabilizationSupported
                // Shoot the photo, using a custom class to handle capture delegate callbacks.
                ///
                
                self.calibrationPointModel.update()
            }
        })
    }
    
    private func renderScreenPoints() {
        let screenGazePoint = ScreenPointModel(cornerRadius: 20,
                                               shadowOpacity: 1,
                                               shadowOffset: .zero,
                                               shadowRadius: 20,
                                               shadowPath: UIBezierPath(rect: gazePoint.bounds).cgPath,
                                               width: 40,
                                               height: 40,
                                               x: 0,
                                               y: 0,
                                               backgroundColor: ColorHelper.UIColorFromRGB(0x1273DE))
        
        let screenCalibrationPoint = ScreenPointModel(cornerRadius: 25,
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
    
    
}
class PhotoCaptureProcessor: NSObject, AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        var z = photo.previewPixelBuffer
        var t = photo.previewCGImageRepresentation()
        var q = photo.fileDataRepresentation()
        var o = UIImage(data: q!)
        var b = 0
        
    }
}
