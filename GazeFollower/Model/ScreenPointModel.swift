//
//  ScreenPointModel.swift
//  GazeFollower
//
//  Created by Paweł Lelental on 14/03/2021.
//

import Foundation
import ARKit

class ScreenPointModel {
    
    public var cornerRadius: CGFloat?
    public var shadowOpacity: Float?
    public var shadowOffset: CGSize?
    public var shadowRadius: CGFloat?
    public var shadowPath: CGPath?
    public var width: Int
    public var height: Int
    public var x: Int
    public var y: Int
    public var backgroundColor: UIColor
    public var withShadowing: Bool
    
    internal init(
        cornerRadius: CGFloat? = nil,
                  shadowOpacity: Float? = nil,
                  shadowOffset: CGSize? = nil,
                  shadowRadius: CGFloat? = nil,
                  shadowPath: CGPath? = nil,
                  width: Int,
                  height: Int,
                  x: Int,
                  y: Int,
                  backgroundColor: UIColor) {
        self.cornerRadius = cornerRadius
        self.shadowOpacity = shadowOpacity
        self.shadowOffset = shadowOffset
        self.shadowRadius = shadowRadius
        self.shadowPath = shadowPath
        self.width = width
        self.height = height
        self.x = x
        self.y = y
        self.backgroundColor = backgroundColor
        self.withShadowing = shadowOpacity != nil
            && shadowPath != nil
            && shadowOffset != nil
            && shadowRadius != nil
    }
   
}
