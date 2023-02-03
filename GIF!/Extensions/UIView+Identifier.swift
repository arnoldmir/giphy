//
//  UIView+Identifier.swift
//  GIF!
//
//  Created by Arnold Mir on 27.01.23.
//

import UIKit

extension UIView {

    static var identifier: String {
        return String(describing: self)
    }
}
