//
//  UIImageViewExtension.swift
//  GazeFollower
//
//  Created by Paweł Lelental on 29/01/2021.
//

import Foundation
import UIKit

extension UIImageView {
    func applyshadowWithCorner(){
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 10
    
    }
}
