//
//  UIExtensions.swift
//  Hush
//
//  Created by Luay Younus on 6/27/17.
//  Copyright © 2017 Luay Younus. All rights reserved.
//

import Foundation
import UIKit

extension UIResponder {
    static var identifier:String {
        return String(describing: self)
    }
}

extension UIImage {
    func scaleDownIcon(for image: UIImage) -> UIImage? {
        let scale = UIScreen.main.scale
        let size = CGSize(width: 30, height: 30)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newIcon = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newIcon
    }
}
