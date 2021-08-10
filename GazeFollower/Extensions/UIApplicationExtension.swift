//
// Created by Paweł Lelental on 10/08/2021.
//

import Foundation
import UIKit

extension UIApplication {
    func getScreenshot() -> UIImage? {
        guard let window: UIWindow = keyWindow else { return nil }
        let bounds = UIScreen.main.bounds
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        window.drawHierarchy(in: bounds, afterScreenUpdates: true)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        return image
    }
}