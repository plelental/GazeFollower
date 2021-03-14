//
//  CalibrationDataModel.swift
//  GazeFollower
//
//  Created by Paweł Lelental on 14/03/2021.
//

import Foundation
import ARKit

class CalibrationDataModel: Codable {
    
    public var date: String
    public var testPointX: Float
    public var testPointY: Float
    public var estimationPointX: Float
    public var estimationPointY: Float
    public var distanceFromDevice: Float
    public var depthDataFileName: String
    public var faceMaskPhotoFileName: String
    public var standardPhotoFileName: String
    public var calibrationStep: String
    
    init(
        date: String,
        testPointX: Float,
        testPointY: Float,
        estimationPointX: Float,
        estimationPointY: Float,
        distanceFromDevice: Float,
        depthDataFileName: String,
        faceMaskPhotoFileName: String,
        standardPhotoFileName: String,
        calibrationStep: String) {
        self.date = date
        self.testPointX = testPointX
        self.testPointY = testPointY
        self.estimationPointX = estimationPointX
        self.estimationPointY = estimationPointY
        self.distanceFromDevice = distanceFromDevice
        self.depthDataFileName = depthDataFileName
        self.faceMaskPhotoFileName = faceMaskPhotoFileName
        self.standardPhotoFileName = standardPhotoFileName
        self.calibrationStep = calibrationStep
    }
    
}
