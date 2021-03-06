//
//  ViewController.swift
//  GazeFollower
//
//  Created by Paweł Lelental on 29/01/2021.
//

import UIKit
import RealityKit

class ViewController: BaseController {
    
    @IBOutlet var arView: ARView!
    @IBOutlet var MainView: UIView!
    @IBOutlet weak var GazeEstimator: UIButton!
    @IBOutlet weak var Calibrate: UIButton!
    @IBOutlet weak var EyeImage: UIImageView!
    @IBOutlet weak var CameraButton: UIButton!    
    
    override func viewDidAppear(_ animated: Bool) {
        super.setUpNavigationBarAfterAppear(hidden: true,animated: animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.barStyle = UIBarStyle.default
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        super.initNavigationBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.hideNavigatonBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        EyeImage.applyshadowWithCorner()
        
        CameraButton.applyGradient(colors: buttonColor())
        CameraButton.applyShadow()
        
        GazeEstimator.applyGradient(colors: buttonColor())
        GazeEstimator.applyShadow()
        
        Calibrate.applyGradient(colors: buttonColor())
        Calibrate.applyShadow()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    override var prefersStatusBarHidden: Bool {
        return navigationController?.isNavigationBarHidden == true
    }
    
    func buttonColor() -> Array<CGColor>{
        return [ColorHelper.UIColorFromRGB(0x1273DE).cgColor,ColorHelper.UIColorFromRGB(0x004DCF).cgColor]
    }
}


