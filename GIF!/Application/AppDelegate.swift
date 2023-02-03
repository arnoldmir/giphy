//
//  AppDelegate.swift
//  GIF!
//
//  Created by Arnold Mir on 27.01.23.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        GIFRouter().createControllers(window: window)
        return true
    }
}
