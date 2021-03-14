//
//  CalibrationPointModel.swift
//  GazeFollower
//
//  Created by Paweł Lelental on 14/03/2021.
//

import Foundation
import ARKit

class CalibrationPointModel {
  
    private var step = 1;
    public var point: CGPoint = CGPoint(x: 25, y: 150)
    public var calibrationStep = CalibrationStep(rawValue: 1)
    
    func update(){
        step += 1
        calibrationStep = CalibrationStep(rawValue: step)
        
        if (step > CalibrationStep.allCases.count - 1) {
            step = 1
        }
        
        point = getPointCoordinates(calibrationStep: step)
    }
    
    private func getPointCoordinates(calibrationStep: Int) -> CGPoint {
        let height = Float(UIScreen.main.bounds.height)
        let width = Float(UIScreen.main.bounds.width)
        
        switch calibrationStep {
        case CalibrationStep.LeftUpperCorner.getStep():
            return CGPoint(x: 25, y: 150)
        case CalibrationStep.LeftBottomCorner.getStep():
            return CGPoint(x: 25, y: Int(height - 150))
        case CalibrationStep.RightBottomCorner.getStep():
            return CGPoint(x: Int(width - 25), y: Int(height - 150))
        case CalibrationStep.RightUpperCorner.getStep():
            return CGPoint(x: Int(width - 25), y: Int(150))
        case CalibrationStep.Center.getStep():
            return CGPoint(x: Int((width) / 2), y: Int((height) / 2))
        default:
            return CGPoint(x: Int(-1),y: Int(-1))
        }
    }
    
}
