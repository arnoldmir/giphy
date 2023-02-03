//
//  TrendingRouter.swift
//  GIF!
//
//  Created by Arnold Mir on 29.01.23.
//

import UIKit

class TrendingRouter: Router {

    func route(to routeID: String, from context: UIViewController, parameters: Any?) {
        guard let route = TrendingViewController.Route(rawValue: routeID) else { return }

        switch route {
        case .details:
            guard let parameters = parameters as? (gifList: GifList?, gifUrl: URL?) else { return }

            goToDetails(context: context, gifList: parameters.gifList, gifUrl: parameters.gifUrl)
        }
    }

    private func goToDetails(context: UIViewController, gifList: GifList?, gifUrl: URL?) {
        let detailsViewController = DetailsViewController.instantiate()
        detailsViewController.viewModel = DetailsViewModel(gifList: gifList, gifUrl: gifUrl, state: .trending)
        if let sheet = detailsViewController.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }

        context.present(detailsViewController, animated: true)
    }
}
