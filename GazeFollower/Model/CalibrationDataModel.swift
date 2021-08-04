//
//  CalibrationDataModel.swift
//  GazeFollower
//
//  Created by Paweł Lelental on 14/03/2021.
//

import Foundation
import ARKit

class CalibrationDataModel: Codable {

    /// Unical Id of calibration step.
    /// Depth and captured photo can be correlated by uuid
    public var uuid: String
    /// Date of calibration step
    public var date: String
    /// Horizontal pixel coordinate of the rendered test point in the screen.
    public var testPointX: Float
    /// Vertical pixel coordinate of the rendered test point in the screen.
    public var testPointY: Float
    /// Horizontal pixel coordinate of the rendered estimated gaze point in the screen.
    public var estimationPointX: Float
    /// Vertical  pixel coordinate of the rendered estimated gaze point in the screen.
    public var estimationPointY: Float
    /// Distance from camera to the user face declared in centimeters
    public var distanceFromDevice: Float
    /// Number of step of the calibration. Range from 1 to 5.
    public var calibrationStep: Int
    /// Number declaring depth data quality. Return one of the two values: 0 for low quality and 1 for high
    /// See more: https://developer.apple.com/documentation/avfoundation/avdepthdata/quality
    public var depthDataQuality: Int
    /// Number declaring depth data accuracy. Return one of the two values: 0 for relative accuracy and 1 for absolute
    /// See more: https://developer.apple.com/documentation/avfoundation/avdepthdata/accuracy
    public var depthDataAccuracy: Int
    /// Flag that decleras whether that depth map contains temporally smoothed data
    /// See more: https://developer.apple.com/documentation/avfoundation/avdepthdata/2881224-isdepthdatafiltered
    public var isDepthDataFiltered: Bool
    /// String returning the pixel format of the depth map.
    /// See more: https://developer.apple.com/documentation/avfoundation/avdepthdata/2881228-depthdatatype
    /// and https://developer.apple.com/documentation/corevideo/1563591-pixel_format_identifiers
    public var depthDataType: String
    /// An elapsed time of the calibration step
    public var elapsedTime: Float

    init(
            uuid: String,
            date: String,
            testPointX: Float,
            testPointY: Float,
            estimationPointX: Float,
            estimationPointY: Float,
            distanceFromDevice: Float,
            calibrationStep: Int,
            depthDataQuality: Int,
            depthDataAccuracy: Int,
            isDepthDataFiltered: Bool,
            depthDataType: String,
            elapsedTime: Float) {
        self.uuid = uuid
        self.date = date
        self.testPointX = testPointX
        self.testPointY = testPointY
        self.estimationPointX = estimationPointX
        self.estimationPointY = estimationPointY
        self.distanceFromDevice = distanceFromDevice
        self.calibrationStep = calibrationStep
        self.depthDataQuality = depthDataQuality
        self.depthDataAccuracy = depthDataAccuracy
        self.isDepthDataFiltered = isDepthDataFiltered
        self.depthDataType = depthDataType
        self.elapsedTime = elapsedTime
    }

}
