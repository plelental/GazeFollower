//
// Created by Paweł Lelental on 14/08/2021.
//

import Foundation
import Foundation
import UIKit

class HeatPoint: Codable {
    public var point: CGPoint
    public var occurrence: Int

    init(point: CGPoint, occurrence: Int) {
        self.point = point
        self.occurrence = occurrence
    }
}