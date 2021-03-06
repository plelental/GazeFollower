//
//  UIImageViewExtension.swift
//  GazeFollower
//
//  Created by Paweł Lelental on 29/01/2021.
//

import Foundation
import UIKit

extension UIImageView {
    func applyShadowWithCorner() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = 10
    }
}
