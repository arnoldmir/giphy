//
//  GIFRouter.swift
//  GIF!
//
//  Created by Arnold Mir on 27.01.23.
//

import UIKit

class GIFRouter: Router {

    func route(to routeID: String, from context: UIViewController, parameters: Any?) { }

    func createControllers(window: UIWindow?, selectedTabBarIndex: Int = 0) {
        window?.rootViewController = MainTabBarController()
    }
}
