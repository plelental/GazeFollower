//
// Created by Paweł Lelental on 22/08/2021.
//

import Foundation
import UIKit
import SceneKit
import ARKit
import MessageUI

class SessionRecordingBaseController: BaseController, MFMailComposeViewControllerDelegate, ARSCNViewDelegate, ARSessionDelegate {

    public var gazePointsList: [Coords] = []
    public var isRecordingSession = false
    public var screenShot: UIImage = UIImage()
    public var isDepthDataCaptured = false
    public var arFrame: ARFrame?
    public var distancesFromDevice: [Int] = []
    public let fileService = FileService()
    public var outputVolumeObserve: NSKeyValueObservation?
    public let audioSession = AVAudioSession.sharedInstance()

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        if (frame.capturedDepthData != nil) {
            arFrame = frame
            isDepthDataCaptured = true
        } else {
            isDepthDataCaptured = false
        }
    }


    func DataToJson(jsonFileName: String) throws {
        guard let readingFile = fileService.getFileUrl(fileName: jsonFileName) else {
            return
        }
        let jsonEncoder = JSONEncoder()

        jsonEncoder.outputFormatting = .prettyPrinted
        let avgDistances = distancesFromDevice.reduce(0, +) / distancesFromDevice.count
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        let timestamp = formatter.string(from: Date())
        let depthData = arFrame?.capturedDepthData

        let jsonData = try jsonEncoder.encode(SessionRecordData(coords: gazePointsList, date: timestamp,
                distanceFromDevice: avgDistances, depthDataQuality: depthData!.depthDataQuality.rawValue,
                depthDataAccuracy: depthData!.depthDataAccuracy.rawValue, isDepthDataFiltered: depthData!.isDepthDataFiltered,
                depthDataType: String(depthData!.depthDataType)))

        try? jsonData.write(to: readingFile, options: .atomicWrite)
    }


    func sendEmail(screenShot: UIImage, fileNameJson: String, fileNameJpeg: String) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["p.lelental@gmail.com"])
            guard let readingFile = fileService.getFileUrl(fileName: fileNameJson) else {
                return
            }
            do {
                let data = try Data(contentsOf: readingFile)
                mail.addAttachmentData(data as Data, mimeType: "application/json", fileName: fileNameJson)
                mail.addAttachmentData(screenShot.jpegData(compressionQuality: CGFloat(1.0))!, mimeType: "image/jpeg", fileName: fileNameJpeg)
            } catch let error {
                print("Encountered error \(error.localizedDescription)")
            }

            present(mail, animated: true)
        } else {
            print("Email cannot be sent")
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let _ = error {
            dismiss(animated: true, completion: nil)
        }
        switch result {
        case .cancelled:
            print("Cancelled")
            break
        case .sent:
            print("Mail sent successfully")
            break
        case .failed:
            print("Sending mail failed")
            break
        default:
            break
        }
        controller.dismiss(animated: true, completion: nil)
    }

    func GenerateTrackingRoute(arView: ARSCNView) {
        for element in gazePointsList {
            let view = UIView()
            renderScreenPointWithColor(width: 30, height: 30, subViewToRender: view, arView: arView, color: ColorHelper.UIColorFromRGB(0xfe11f))
            view.center = CGPoint(x: element.x, y: element.y)
        }
    }
    func GenerateTrackingRoute(mainView: UIView) {
        for element in gazePointsList {
            let view = UIView()
            renderScreenPointWithColor(width: 30, height: 30, subViewToRender: view, mainView: mainView, color: ColorHelper.UIColorFromRGB(0xfe11f))
            view.center = CGPoint(x: element.x, y: element.y)
        }
    }

    func ShowAlert(title: String, message: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: handler))
        present(alert, animated: true)
    }

    func GenerateCoords(point: CGPoint) -> Coords {
        Coords(x: Int(point.x), y: Int(point.y))
    }
}
