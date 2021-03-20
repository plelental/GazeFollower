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
    public var standardPhotoFileName: String
    public var calibrationStep: String
    public var depthDataQuality: String
    public var depthDataAccuracy: String
    public var isDepthDataFiltered: Bool
    public var depthDataType: String
    
    
    init(
        date: String,
        testPointX: Float,
        testPointY: Float,
        estimationPointX: Float,
        estimationPointY: Float,
        distanceFromDevice: Float,
        depthDataFileName: String,
        standardPhotoFileName: String,
        calibrationStep: String,
        depthDataQuality: String,
        depthDataAccuracy: String,
        isDepthDataFiltered: Bool,
        depthDataType: String) {
        self.date = date
        self.testPointX = testPointX
        self.testPointY = testPointY
        self.estimationPointX = estimationPointX
        self.estimationPointY = estimationPointY
        self.distanceFromDevice = distanceFromDevice
        self.depthDataFileName = depthDataFileName
        self.standardPhotoFileName = standardPhotoFileName
        self.calibrationStep = calibrationStep
        self.depthDataQuality = depthDataQuality
        self.depthDataAccuracy = depthDataAccuracy
        self.isDepthDataFiltered = isDepthDataFiltered
        self.depthDataType = depthDataType
    }
    
}
