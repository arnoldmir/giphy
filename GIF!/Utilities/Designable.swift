//
//  Designable.swift
//  GIF!
//
//  Created by Arnold Mir on 29.01.23.
//

import UIKit

@IBDesignable
class DesignableView: UIView {}

@IBDesignable
class DesignableButton: UIButton {}

extension UIView {

    @IBInspectable
    var cornerRadiusCustom: CGFloat {
        get { return layer.cornerRadius }
        set { layer.cornerRadius = newValue }
    }
}
