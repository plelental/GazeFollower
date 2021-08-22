//
// Created by Paweł Lelental on 22/08/2021.
//

import Foundation

class SessionRecordData: Codable {

    // Collection of estimation points coordinates
    public var coords: [Coords]
    /// Date of recording
    public var date: String
    /// Distance from camera to the user face declared in centimeters
    public var distanceFromDevice: Int
    /// Number declaring depth data quality. Return one of the two values: 0 for low quality and 1 for high
    /// See more: https://developer.apple.com/documentation/avfoundation/avdepthdata/quality
    public var depthDataQuality: Int
    /// Number declaring depth data accuracy. Return one of the two values: 0 for relative accuracy and 1 for absolute
    /// See more: https://developer.apple.com/documentation/avfoundation/avdepthdata/accuracy
    public var depthDataAccuracy: Int
    /// Flag that declares whether that depth map contains temporally smoothed data
    /// See more: https://developer.apple.com/documentation/avfoundation/avdepthdata/2881224-isdepthdatafiltered
    public var isDepthDataFiltered: Bool
    /// String returning the pixel format of the depth map.
    /// See more: https://developer.apple.com/documentation/avfoundation/avdepthdata/2881228-depthdatatype
    /// and https://developer.apple.com/documentation/corevideo/1563591-pixel_format_identifiers
    public var depthDataType: String

    init(coords: [Coords], date: String, distanceFromDevice: Int, depthDataQuality: Int, depthDataAccuracy: Int, isDepthDataFiltered: Bool, depthDataType: String) {
        self.coords = coords
        self.date = date
        self.distanceFromDevice = distanceFromDevice
        self.depthDataQuality = depthDataQuality
        self.depthDataAccuracy = depthDataAccuracy
        self.isDepthDataFiltered = isDepthDataFiltered
        self.depthDataType = depthDataType
    }
}
