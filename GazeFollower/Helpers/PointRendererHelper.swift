//
//  PointRendererHelper.swift
//  GazeFollower
//
//  Created by Paweł Lelental on 06/03/2021.
//

import Foundation
import ARKit

class PointRendererHelper{
    var positions: Array<simd_float2> = Array()

    func smoothRenderingOfTheProjectedPoints(pointX: Float, pointY: Float) -> simd_float2 {

        positions.append(simd_float2(pointX, pointY));

        if positions.count > 5 {
            positions.removeFirst()
        }

        var total = simd_float2(0, 0);

        for pos in positions {
            total.x += pos.x
            total.y += pos.y
        }

        total.x /= Float(positions.count)
        total.y /= Float(positions.count)

        return total
    }
}
