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
