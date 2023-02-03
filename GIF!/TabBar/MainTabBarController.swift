//
//  MainTabBarController.swift
//  GIF!
//
//  Created by Arnold Mir on 27.01.23.
//

import UIKit

protocol TabBarItemController: AnyObject {
    func scrollToTop()
}

private enum StringResources {
    static let trending = "Trending"
    static let trendingImage = "chart.line.uptrend.xyaxis.circle"
    static let trendingSelectedImage = "chart.line.uptrend.xyaxis.circle.fill"
    static let favorite = "Favorite"
    static let favoriteImage = "heart"
    static let favoriteSelectedImage = "heart.fill"
}

enum TabBarControllers: Int {
    case trending
    case favorite
}

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        createTabBarController()
    }

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let selectedIndex = tabBar.items?.firstIndex(of: item),
              self.selectedIndex == selectedIndex else { return }

        let navigationController = viewControllers?[selectedIndex] as? UINavigationController
        let tabBarItemViewController = navigationController?.visibleViewController as? TabBarItemController

        tabBarItemViewController?.scrollToTop()
    }

    private func setupView() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.shadowImage = nil
        appearance.shadowColor = nil
        tabBar.standardAppearance = appearance

        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
    }

    private func createTabBarController() {
        tabBar.isHidden = false
        tabBar.backgroundColor = .black
        tabBar.barTintColor = .black
        viewControllers = prepareTabBarControllers()
        selectedIndex = TabBarControllers.trending.rawValue
        tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        tabBar.clipsToBounds = true
        tabBar.isTranslucent = false
        tabBar.barStyle = .black
        tabBar.clipsToBounds = true
    }

    private func prepareTabBarControllers() -> [UINavigationController] {
        var tabBarControllers: [UINavigationController] = []

        let trendingViewController = TrendingViewController.instantiate()
        trendingViewController.router = TrendingRouter()
        trendingViewController.viewModel = TrendingViewModel()
        let trendingNavigationController = createNavigationController(withRoot: trendingViewController)
        trendingViewController.title = StringResources.trending
        trendingNavigationController.navigationItem.largeTitleDisplayMode = .automatic
        let trendingTabbarItem = UITabBarItem(title: StringResources.trending,
                                              image: UIImage(systemName: StringResources.trendingImage),
                                              selectedImage: UIImage(systemName: StringResources.trendingSelectedImage))
        trendingNavigationController.tabBarItem = trendingTabbarItem
        tabBarControllers.append(trendingNavigationController)

        let favoriteViewController = FavoriteViewController.instantiate()
        favoriteViewController.viewModel = FavoriteViewModel()
        favoriteViewController.router = FavoriteRouter()
        let favoriteNavigationController = createNavigationController(withRoot: favoriteViewController)
        favoriteViewController.title = StringResources.favorite
        let favoriteTabbarItam = UITabBarItem(title: StringResources.favorite,
                                              image: UIImage(systemName: StringResources.favoriteImage),
                                              selectedImage: UIImage(systemName: StringResources.favoriteSelectedImage))
        favoriteNavigationController.tabBarItem = favoriteTabbarItam
        tabBarControllers.append(favoriteNavigationController)

        return tabBarControllers
    }

    private func createNavigationController(withRoot viewController: UIViewController) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: viewController)

        let standard = UINavigationBarAppearance()
        standard.shadowImage = nil
        standard.shadowColor = nil
        standard.backgroundColor = .black
        navigationController.navigationBar.standardAppearance = standard
        navigationController.navigationBar.compactAppearance = standard
        navigationController.navigationBar.scrollEdgeAppearance = standard
        navigationController.navigationBar.prefersLargeTitles = true

        if #available(iOS 15.0, *) {
            navigationController.navigationBar.compactScrollEdgeAppearance = standard
        }

        return navigationController
    }
}
