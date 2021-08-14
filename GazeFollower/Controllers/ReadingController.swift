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

class ReadingController: BaseController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet weak var gazeView: ARSCNView!
    @IBOutlet weak var textToRead: UILabel!

    private let scnVectorHelper = SCNVectorHelper()
    private var faceModel: FaceModel!
    private var gazePointView: UIView = UIView()
    private var gazePointsList: [RenderPoint] = []
    private var isRecordingSession = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpARSCNView(view: gazeView, viewDelegate: self, arSessionDelegate: self)
        faceModel = FaceModel(view: gazeView)
        textToRead.text = ReadingConstants.readingText
        DoubleTabListener()
    }

    override func viewDidAppear(_ animated: Bool) {
        setUpNavigationBarAfterAppear(hidden: false, animated: animated)
        ShowAlert(title: "Recording session",
                message: "The reading session after clicking \"Ok\" button will be recorded. To stop recording tap twice on the screen",
                handler: { _ in _ = self.isRecordingSession = true })

        renderScreenPoint(width: 30, height: 30, subViewToRender: gazePointView, arView: gazeView)
    }

    override func viewWillAppear(_ animated: Bool) {
        initNavigationBar()
        setUpARSession(view: gazeView)
        gazeView.scene.background.contents = UIColor.white
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.hideNavigationBar()
        gazeView.session.pause()
    }

    @objc func doubleTapped() {
        isRecordingSession = false
        GenerateHeatMap()
        UIApplication.shared.getScreenshot()
        ShowAlert(title: "Saving recording session",
                message: "The recording session has stopped and has been saved",
                handler: { _ in _ = self.navigationController?.popToRootViewController(animated: true) })
    }

    private func GenerateHeatMap() {
        let dictionary = Dictionary(grouping: gazePointsList, by: { element in element.key })

        var heatMaps: [HeatPoint] = []

        for (_, value) in dictionary {
            heatMaps.append(HeatPoint(point: value.first!.point, occurrence: value.count))
        }

        let lowestHeatValues = heatMaps.filter {
            $0.occurrence == 1
        }
        var highestHeatValues = heatMaps.filter {
            $0.occurrence > 1
        }

        for lowestHeat in lowestHeatValues {
            let view = UIView()
            renderScreenPointWithColor(width: 30, height: 30, subViewToRender: view, arView: gazeView, rgbColor: 0x00ede9)
            view.center = lowestHeat.point
        }

        highestHeatValues.sort(by: { $0.occurrence > $1.occurrence })
        let occurrencesSet = NSSet(array: highestHeatValues.map {
            $0.occurrence
        })
        let distinctCount = occurrencesSet.count
        let incrementer = (100 / distinctCount)


        for (index, element) in highestHeatValues.enumerated() {
            let view = UIView()
            if (index == 0) {
                renderScreenPointWithColor(width: 30, height: 30, subViewToRender: view, arView: gazeView, color: ColorHelper.UIColorFromRGB(0xfe11f))
            } else {
                var heatedColor = ColorHelper
                        .UIColorFromRGB(0xfe11f)
                        .darker(by: CGFloat(element.occurrence * incrementer))
                if (heatedColor?.toHexString() == "#000000") {
                    heatedColor = ColorHelper.UIColorFromRGB(0xe30000)
                }
                renderScreenPointWithColor(width: 30, height: 30, subViewToRender: view, arView: gazeView, color: heatedColor!)

            }
            view.center = element.point

        }
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for faceAnchor: ARAnchor) {
        guard #available(iOS 12.0, *), let faceAnchor = faceAnchor as? ARFaceAnchor
                else {
            return
        }

        faceModel.update(faceAnchor: faceAnchor, view: gazeView, node: node)

        DispatchQueue.main.async(execute: { () -> Void in
            let point = self.faceModel.estimationPointOnTheScreen
            self.gazePointView.center = point
            if (self.isRecordingSession) {
                self.gazePointsList.append(self.CreateRenderPoint(point: point))
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

    private func DoubleTabListener() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tap.numberOfTapsRequired = 2
        view.addGestureRecognizer(tap)
    }

    private func ShowAlert(title: String, message: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: handler))
        present(alert, animated: true)
    }

    private func CreateRenderPoint(point: CGPoint) -> RenderPoint {
        let x = String(format: "%.f", point.x)
        let y = String(format: "%.f", point.y)
        let key = "\(x)\(y)"
        let renderPoint = RenderPoint(key: key, point: point)
        return renderPoint
    }
}
