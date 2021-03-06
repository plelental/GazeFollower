//
//  SCNVectorHelper.swift
//  GazeFollower
//
//  Created by Paweł Lelental on 06/03/2021.
//

import Foundation
import ARKit

class SCNVectorHelper {
    func createSCNVectorFromSimdFloat3(simdFloats3: simd_float3) -> SCNVector3 {
        SCNVector3(simdFloats3.x, simdFloats3.y, simdFloats3.z)
    }

    func createSCNVectorFromSimdFloat4(simdFloats4: simd_float4) -> SCNVector3 {
        SCNVector3(simdFloats4.x, simdFloats4.y, simdFloats4.z)
    }

    func createSCNVectorFromSimdFloat3FromTwo(firstSimdFloats3: simd_float4, secondSimdFloats3: simd_float4) -> SCNVector3 {
        let x = (firstSimdFloats3.x + secondSimdFloats3.x) / 2
        let y = (firstSimdFloats3.y + secondSimdFloats3.y) / 2
        let z = (firstSimdFloats3.z + secondSimdFloats3.z) / 2
        return SCNVector3(x, y, z)
    }
}
