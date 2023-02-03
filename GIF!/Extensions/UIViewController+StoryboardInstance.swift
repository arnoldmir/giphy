//
//  UIViewController+StoryboardInstance.swift
//  GIF!
//
//  Created by Arnold Mir on 27.01.23.
//

import UIKit

extension UIViewController {

    static func storyboardInstance() -> UIViewController? {
        let storyboard = UIStoryboard(name: String(describing: self), bundle: nil)
        return storyboard.instantiateInitialViewController()
    }
}
