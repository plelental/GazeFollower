//  ViewController.swift
//
//  GazeFollower
//
//  Created by Paweł Lelental on 29/01/2021.
//

import UIKit
import RealityKit

class ViewController: BaseController {

    @IBOutlet var mainView: UIView!
    @IBOutlet var recordReadingButton: UIButton!
    @IBOutlet var webBrowserButton: UIButton!
    @IBOutlet weak var eyeImage: UIImageView!
    @IBOutlet weak var cameraButton: UIButton!

    override func viewDidAppear(_ animated: Bool) {
        super.setUpNavigationBarAfterAppear(hidden: true, animated: animated)
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.barStyle = UIBarStyle.default
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        super.initNavigationBar()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.hideNavigationBar()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        eyeImage.applyShadowWithCorner()

        cameraButton.applyGradient(colors: buttonColor())
        cameraButton.applyShadow()

        recordReadingButton.applyGradient(colors: buttonColor())
        recordReadingButton.applyShadow()

        webBrowserButton.applyGradient(colors: buttonColor())
        webBrowserButton.applyShadow()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }

    override var prefersStatusBarHidden: Bool {
        navigationController?.isNavigationBarHidden == true
    }

    func buttonColor() -> Array<CGColor> {
        [ColorHelper.UIColorFromRGB(0x1273DE).cgColor, ColorHelper.UIColorFromRGB(0x004DCF).cgColor]
    }
}


