//
//  SCNVector3Extension.swift
//  GazeFollower
//
//  Created by Paweł Lelental on 20/03/2021.
//

import Foundation
import ARKit

extension SCNVector3 {

    func length() -> Float {
        sqrtf(x * x + y * y + z * z)
    }

    static func -(l: SCNVector3, r: SCNVector3) -> SCNVector3 {
        SCNVector3Make(l.x - r.x, l.y - r.y, l.z - r.z)
    }
}
