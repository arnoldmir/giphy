//
//  RouterProtocol.swift
//  GIF!
//
//  Created by Arnold Mir on 3.02.23.
//

import UIKit

protocol Router {
    func route(to routeID: String, from context: UIViewController, parameters: Any?)
}
