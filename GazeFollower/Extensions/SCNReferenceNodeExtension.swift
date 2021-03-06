//
//  SCNReferenceNodeExtension.swift
//  GazeFollower
//
//  Created by Paweł Lelental on 30/01/2021.
//

import Foundation
import ARKit
import SceneKit

extension SCNReferenceNode {
    convenience init(named resourceName: String, loadImmediately: Bool = true) {
        let url = Bundle.main.url(forResource: resourceName, withExtension: "scn")!
        self.init(url: url)!
        if loadImmediately {
            load()
        }
    }
}

