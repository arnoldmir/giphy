//
//  PresentableProtocol.swift
//  GIF!
//
//  Created by Arnold Mir on 2.02.23.
//

import UIKit

protocol PresentableProtocol {

    // MARK: - Properties
    static var storyboardName: String { get }
    static var storyboardBundle: Bundle { get }

    // MARK: - Helper Methods
    static func instantiate() -> Self
}

extension PresentableProtocol where Self: UIViewController {

    // MARK: - Helper Properties
    static var storyboardName: String {
        return String(describing: self)
    }

    static var storyboardBundle: Bundle {
        return .main
    }

    // MARK: - Helper Methods
    static func instantiate() -> Self {
        guard let viewController = UIStoryboard(name: storyboardName,
                                                bundle: storyboardBundle).instantiateInitialViewController() as? Self
        else {
            fatalError("Unable to Instantiate View Controller With Storyboard Bundle")
        }
        return viewController
    }
}
