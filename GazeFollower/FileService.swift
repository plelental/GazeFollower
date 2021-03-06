//
//  FileService.swift
//  GazeFollower
//
//  Created by Paweł Lelental on 06/03/2021.
//

import Foundation

class FileService{
    
    func getCalibrationFileUrl() -> URL? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        
        let fileName = "gazefollower_calibration_data.txt"
        return documentsDirectory.appendingPathComponent(fileName)
    }
    
}
