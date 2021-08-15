//
// Created by Paweł Lelental on 15/08/2021.
//

import Foundation

class Coords: Codable {
    public var x: Int
    public var y: Int

    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
}
