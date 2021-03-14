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
    
    func saveCalibrateDataPoint(calibrationPoint: CGPoint, estimationPoint: CGPoint, distance: Float, calibrationStep: CalibrationStep) {
        
        guard let calibrationFile = fileService.getCalibrationFileUrl() else {
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        let timestamp = formatter.string(from: Date())
        
        
        let calibrationPointModel = CalibrationDataModel(date: timestamp,
                                                         testPointX: Float(calibrationPoint.x),
                                                         testPointY: Float(calibrationPoint.y),
                                                         estimationPointX: Float(estimationPoint.x),
                                                         estimationPointY: Float(estimationPoint.y),
                                                         distanceFromDevice: distance,
                                                         depthDataFileName: "",
                                                         faceMaskPhotoFileName: "",
                                                         standardPhotoFileName: "",
                                                         calibrationStep: calibrationStep.rawValue.description)
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let json = try encoder.encode(calibrationPointModel);
            
            if FileManager.default.fileExists(atPath: calibrationFile.path) {
                if let fileHandle = try? FileHandle(forWritingTo: calibrationFile) {
                    fileHandle.seekToEndOfFile()
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
}
