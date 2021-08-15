//
// Created by Paweł Lelental on 14/08/2021.
//

import Foundation
import UIKit

extension UIColor {
    func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        getRed(&r, green: &g, blue: &b, alpha: &a)

        let rgb: Int = (Int)(r * 255) << 16 | (Int)(g * 255) << 8 | (Int)(b * 255) << 0

        return String(format: "#%06x", rgb)
    }

    func lighter(by percentage: CGFloat = 30.0) -> UIColor? {
        adjust(by: abs(percentage))
    }

    func darker(by percentage: CGFloat = 30.0) -> UIColor? {
        adjust(by: -1 * abs(percentage))
    }

    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + percentage / 100, 1.0),
                    green: min(green + percentage / 100, 1.0),
                    blue: min(blue + percentage / 100, 1.0),
                    alpha: alpha)
        } else {
            return nil
        }
    }
    func toColor(_ color: UIColor, percentage: CGFloat) -> UIColor {
        let percentage = max(min(percentage, 100), 0) / 100
        switch percentage {
        case 0: return self
        case 1: return color
        default:
            var (r1, g1, b1, a1): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
            var (r2, g2, b2, a2): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
            guard self.getRed(&r1, green: &g1, blue: &b1, alpha: &a1) else { return self }
            guard color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2) else { return self }

            return UIColor(red: CGFloat(r1 + (r2 - r1) * percentage),
                    green: CGFloat(g1 + (g2 - g1) * percentage),
                    blue: CGFloat(b1 + (b2 - b1) * percentage),
                    alpha: CGFloat(a1 + (a2 - a1) * percentage))
        }
    }
}
