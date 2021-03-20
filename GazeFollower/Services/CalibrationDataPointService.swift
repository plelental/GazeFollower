//
//  CalibrationDataPointService.swift
//  GazeFollower
//
//  Created by Paweł Lelental on 14/03/2021.
//

import Foundation
import ARKit

class CalibrationDataPointService {
    
    private var fileService = FileService()
    
    func saveCalibrateDataPoint(calibrationPoint: CGPoint, estimationPoint: CGPoint, distance: Float, arFrame: ARFrame, calibrationStep: CalibrationStepEnum) {
        
        guard let calibrationFile = fileService.getFileUrl(fileName: Constants.calibrationDataFileName) else {
            return
        }
        
        let uuid = UUID().uuidString.lowercased()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        let timestamp = formatter.string(from: Date())
        let depthData = arFrame.capturedDepthData
        saveBufferAsJpegImage(image: arFrame.capturedDepthData!.depthDataMap, fileName: uuid, type:  Constants.depthType)
        saveBufferAsJpegImage(image: arFrame.capturedImage, fileName: uuid, type: Constants.imageType)
        
        let calibrationPointModel = CalibrationDataModel(
            uuid: uuid,
            date: timestamp,
            testPointX: Float(calibrationPoint.x),
            testPointY: Float(calibrationPoint.y),
            estimationPointX: Float(estimationPoint.x),
            estimationPointY: Float(estimationPoint.y),
            distanceFromDevice: distance,
            calibrationStep: calibrationStep.rawValue.description,
            depthDataQuality: String(depthData!.depthDataQuality.rawValue.description),
            depthDataAccuracy: String(depthData!.depthDataAccuracy.rawValue.description),
            isDepthDataFiltered: depthData!.isDepthDataFiltered,
            depthDataType: String(depthData!.depthDataType))
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let json = try encoder.encode(calibrationPointModel);
            if FileManager.default.fileExists(atPath: calibrationFile.path) {
                if let fileHandle = try? FileHandle(forWritingTo: calibrationFile) {
                    let separator  = ",".data(using: .utf8)
                    fileHandle.seekToEndOfFile()
                    fileHandle.write(separator!)
                    fileHandle.write(json)
                    fileHandle.closeFile()
                }
            } else {
                try? json.write(to: calibrationFile, options: .atomicWrite)
            }
            
        } catch {
            print("Error during saving calibration data")
        }
    }
    
    private func saveBufferAsJpegImage(image: CVPixelBuffer, fileName: String, type: String) {
        let fileName = "\(fileName)_\(type).jpg"
        let fileUrl = fileService.getFileUrl(fileName: fileName)
        let image = UIImage(ciImage: CIImage(cvPixelBuffer: image))
        if let data = image.jpegData(compressionQuality: 0.8){
            try? data.write(to: fileUrl!)
        }
    }
}
