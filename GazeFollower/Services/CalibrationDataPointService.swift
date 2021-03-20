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
    
    func saveCalibrateDataPoint(calibrationPoint: CGPoint, estimationPoint: CGPoint, distance: Float, arFrame: ARFrame, calibrationStep: CalibrationStep) {
        
        let fileName = "gazefollower_calibration_data.json"
        guard let calibrationFile = fileService.getFileUrl(fileName: fileName) else {
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        let timestamp = formatter.string(from: Date())
        let depthData = arFrame.capturedDepthData
        let depthImageName = saveBufferAsJpegImageAndGetFileName(image: arFrame.capturedDepthData!.depthDataMap, timestamp: timestamp, type: "depth")
        let imageName = saveBufferAsJpegImageAndGetFileName(image: arFrame.capturedImage, timestamp: timestamp, type: "image")
        

        let calibrationPointModel = CalibrationDataModel(date: timestamp,
                                                         testPointX: Float(calibrationPoint.x),
                                                         testPointY: Float(calibrationPoint.y),
                                                         estimationPointX: Float(estimationPoint.x),
                                                         estimationPointY: Float(estimationPoint.y),
                                                         distanceFromDevice: distance,
                                                         depthDataFileName: depthImageName,
                                                         standardPhotoFileName: imageName,
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
    
    private func saveBufferAsJpegImageAndGetFileName(image: CVPixelBuffer, timestamp: String, type: String) -> String {
        let fileName = "\(timestamp)_\(type).jpg"
        let fileUrl = fileService.getFileUrl(fileName: fileName)
        let image = UIImage(ciImage: CIImage(cvPixelBuffer: image))
        if let data = image.jpegData(compressionQuality: 0.8){
            try? data.write(to: fileUrl!)
        }
        return fileName    }
}
