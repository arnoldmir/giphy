//
//  FavoriteRouter.swift
//  GIF!
//
//  Created by Arnold Mir on 31.01.23.
//

import UIKit

class FavoriteRouter: Router {

    func route(to routeID: String, from context: UIViewController, parameters: Any?) {
        guard let route = FavoriteViewController.Route(rawValue: routeID) else { return }

        switch route {
        case .details:
            guard let parameter = parameters as? GifList? else { return }

            goToDetails(context: context, gifList: parameter)
        }
    }

    private func goToDetails(context: UIViewController, gifList: GifList?) {
        let detailsViewController = DetailsViewController.instantiate()
        detailsViewController.delegate = context as? DetailsViewControllerDelegate
        detailsViewController.viewModel = DetailsViewModel(gifList: gifList, state: .favorite)
        if let sheet = detailsViewController.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }

        context.present(detailsViewController, animated: true)
    }
}
