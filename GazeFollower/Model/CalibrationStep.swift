//
//  CalibrationStep.swift
//  GazeFollower
//
//  Created by Paweł Lelental on 14/03/2021.
//

import Foundation


enum CalibrationStep: Int, CaseIterable {
    
    case OutOfTheScreen = 0
    case LeftUpperCorner = 1
    case LeftBottomCorner = 2
    case RightBottomCorner = 3
    case RightUpperCorner = 4
    case Center = 5
    
    func getStep() -> Int {
        return self.rawValue
    }
}
