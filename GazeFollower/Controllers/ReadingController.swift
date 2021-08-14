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

class RenderPoint: Codable {
    public var key: String
    public var point: CGPoint

    init(key: String, point: CGPoint) {
        self.key = key
        self.point = point
    }

}

class HeatPoint: Codable {
    public var point: CGPoint
    public var occurrence: Int

    init(point: CGPoint, occurrence: Int) {
        self.point = point
        self.occurrence = occurrence
    }

}
extension UIColor {
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0

        getRed(&r, green: &g, blue: &b, alpha: &a)

        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0

        return String(format:"#%06x", rgb)
    }
}

extension UIColor {

    func lighter(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: abs(percentage))
    }

    func darker(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage))
    }

    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + percentage / 100, 1.0),
                    green: min(green + percentage / 100, 1.0),
                    blue: min(blue + percentage / 100, 1.0),
                    alpha: alpha)
        } else {
            return nil
        }
    }
}

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

        var color = ColorHelper.UIColorFromRGB(0xfe11f)

        for (index, element) in highestHeatValues.enumerated() {
            let view = UIView()
            if (index == 0) {
                renderScreenPointWithColor(width: 30, height: 30, subViewToRender: view, arView: gazeView, color: ColorHelper.UIColorFromRGB(0xfe11f))
            } else {
                if (highestHeatValues[index - 1].occurrence < element.occurrence) {
                    color = color.darker(by: CGFloat(incrementer))!
                }
                let heatedColor = color.darker(by: CGFloat(element.occurrence * incrementer))
                if(heatedColor?.toHexString() == "#000000"){
                    color = ColorHelper.UIColorFromRGB(0xe30000)
                }
                renderScreenPointWithColor(width: 30, height: 30, subViewToRender: view, arView: gazeView, color: heatedColor!)

            }
            view.center = element.point

        }


        UIApplication.shared.getScreenshot()
        ShowAlert(title: "Saving recording session",
                message: "The recording session has stopped and has been saved",
                handler: { _ in _ = self.navigationController?.popToRootViewController(animated: true) })
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
                let x = String(format: "%.f", point.x)
                let y = String(format: "%.f", point.y)
                let key = "\(x)\(y)"
                let renderPoint = RenderPoint(key: key, point: point)
                self.gazePointsList.append(renderPoint)
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
}
