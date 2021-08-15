//
//  CGPointExtension.swift
//  GazeFollower
//
//  Created by Paweł Lelental on 13/03/2021.
//

import Foundation
import UIKit
import SceneKit


extension CGPoint {
    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    static func /(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
    }

    static func *(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }
}

extension Array where Element == CGPoint {
    func mean() -> CGPoint? {
        if isEmpty {
            return nil
        }

        return reduce(.zero, +) / CGFloat(count)
    }

    func median() -> CGPoint? {
        if isEmpty {
            return nil
        }

        func calculateMedian(array: [Int]) -> CGFloat {
            let sorted = array.sorted()
            if sorted.count % 2 == 0 {
                return CGFloat((sorted[(sorted.count / 2)] + sorted[(sorted.count / 2) - 1])) / 2
            } else {
                return CGFloat(sorted[(sorted.count - 1) / 2])
            }
        }

        var xArray: [Int] = []
        var yArray: [Int] = []

        for value in self {
            xArray.append(Int(value.x))
            yArray.append(Int(value.y))
        }

        return CGPoint(x: calculateMedian(array: xArray), y: calculateMedian(array: yArray))
    }
}
