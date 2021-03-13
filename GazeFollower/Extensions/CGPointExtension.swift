//
//  CGPointExtension.swift
//  GazeFollower
//
//  Created by Paweł Lelental on 13/03/2021.
//

import Foundation
import UIKit
import SceneKit

func + (first: CGPoint, second: CGPoint) -> CGPoint {
    return CGPoint(x: first.x + second.x, y: first.y + second.y)
}

func / (first: CGPoint, second: CGFloat) -> CGPoint {
    return CGPoint(x: first.x / second, y: first.y / second)
}

extension Collection where Element == CGPoint, Index == Int {
    var average: CGPoint? {
        guard !isEmpty else {
            return CGPoint()
        }

        let sum: CGPoint = reduce(CGPoint(x: 0, y: 0)) { first, second -> CGPoint in
            return first + second
        }

        return sum / CGFloat(count)
    }
}
