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
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var gazeEstimator: UIButton!
    @IBOutlet weak var calibrate: UIButton!
    @IBOutlet weak var EyeImage: UIImageView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var saveDataButton: UIButton!

    private let fileService = FileService()

    @IBAction func onClick(_ sender: UIButton, forEvent event: UIEvent) {
        guard let url = fileService.getCalibrationFileUrl() else {
            return
        }
        do {
            let data = try String(contentsOf: url)
            let activityViewController = UIActivityViewController(activityItems: [data], applicationActivities: nil)
            present(activityViewController, animated: true, completion: nil)
        } catch {
            let alert = UIAlertController(title: "No calibration data available", message: "To save the data, please first process the calibration step", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

            present(alert, animated: true)
        }
    }


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
        EyeImage.applyShadowWithCorner()

        cameraButton.applyGradient(colors: buttonColor())
        cameraButton.applyShadow()

        gazeEstimator.applyGradient(colors: buttonColor())
        gazeEstimator.applyShadow()

        calibrate.applyGradient(colors: buttonColor())
        calibrate.applyShadow()

        saveDataButton.applyGradient(colors: buttonColor())
        saveDataButton.applyShadow()
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


