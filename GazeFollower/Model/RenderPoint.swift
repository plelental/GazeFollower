//
// Created by Paweł Lelental on 14/08/2021.
//

import Foundation
import UIKit
import Foundation

class RenderPoint: Codable {
    public var key: String
    public var point: CGPoint

    init(key: String, point: CGPoint) {
        self.key = key
        self.point = point
    }
}