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
        return UIColor(red: ((CGFloat)((rgbValue & 0xFF0000) >> 16)) / 255.0,
                green: ((CGFloat)((rgbValue & 0x00FFF0) >> 8)) / 255.0,
                blue: ((CGFloat)((rgbValue & 0x0000FF))) / 255.0,
                alpha: 1.0)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }

    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillAppear(_ animated: Bool) {

        self.navigationController?.navigationBar.barStyle = UIBarStyle.default
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.isTranslucent = false
    }

    override var prefersStatusBarHidden: Bool {
        return navigationController?.isNavigationBarHidden == true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        EyeImage.applyshadowWithCorner()
        CameraButton.applyGradient(
                colors: [UIColorFromRGB(0x1273DE).cgColor,
                         UIColorFromRGB(0x004DCF).cgColor])
        CameraButton.applyShadow()
        GazeEstimator.applyGradient(
                colors: [UIColorFromRGB(0x1273DE).cgColor,
                         UIColorFromRGB(0x004DCF).cgColor])
        GazeEstimator.applyShadow()
        Calibrate.applyGradient(
                colors: [UIColorFromRGB(0x1273DE).cgColor,
                         UIColorFromRGB(0x004DCF).cgColor])
        Calibrate.applyShadow()
    }

}

extension UINavigationController {
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
}


