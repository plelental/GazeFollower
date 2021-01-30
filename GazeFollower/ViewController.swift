//
//  ViewController.swift
//  GazeFollower
//
//  Created by Paweł Lelental on 29/01/2021.
//

import UIKit
import RealityKit

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    @IBOutlet var MainView: UIView!
    @IBOutlet weak var GazeEstimator: UIButton!
    @IBOutlet weak var Calibrate: UIButton!
    @IBOutlet weak var EyeImage: UIImageView!
    @IBOutlet weak var CameraButton: UIButton!
    
    func UIColorFromRGB(_ rgbValue: Int) -> UIColor {
        return UIColor(red: ((CGFloat)((rgbValue & 0xFF0000) >> 16))/255.0, green: ((CGFloat)((rgbValue & 0x00FFF0) >> 8))/255.0, blue: ((CGFloat)((rgbValue & 0x0000FF)))/255.0, alpha: 1.0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        EyeImage.applyshadowWithCorner()
        CameraButton.applyGradient(colors: [UIColorFromRGB(0x2B95CE).cgColor,UIColorFromRGB(0x2ECAD5).cgColor])
        CameraButton.applyshadowWithCorner()
        GazeEstimator.applyGradient(colors: [UIColorFromRGB(0x2B95CE).cgColor,UIColorFromRGB(0x2ECAD5).cgColor])
        GazeEstimator.applyshadowWithCorner()
        Calibrate.applyGradient(colors: [UIColorFromRGB(0x2B95CE).cgColor,UIColorFromRGB(0x2ECAD5).cgColor])
        Calibrate.applyshadowWithCorner()
    }
    
}


