//
//  ColorHelper.swift
//  GazeFollower
//
//  Created by Paweł Lelental on 06/03/2021.
//

import Foundation

class ColorHelper{
    func UIColorFromRGB(_ rgbValue: Int) -> UIColor {
        return UIColor(red: ((CGFloat)((rgbValue & 0xFF0000) >> 16)) / 255.0,
                       green: ((CGFloat)((rgbValue & 0x00FFF0) >> 8)) / 255.0,
                       blue: ((CGFloat)((rgbValue & 0x0000FF))) / 255.0,
                       alpha: 1.0)
    }
}
