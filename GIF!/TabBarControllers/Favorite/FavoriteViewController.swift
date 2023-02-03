//
//  FavoriteViewController.swift
//  GIF!
//
//  Created by Arnold Mir on 27.01.23.
//

import UIKit

private enum NumbersResources {
    static let itemWidthDimension: CGFloat = 1/3
    static let itemHeightDimension: CGFloat = 1
    static let itemTop: CGFloat = 0
    static let itemLeading: CGFloat = 4
    static let itemBottom: CGFloat = 0
    static let itemTrailing: CGFloat = 4
    static let groupWidthDimension: CGFloat = 1
    static let groupHeightDimension: CGFloat = 2/5
    static let groupTop: CGFloat = 8
    static let groupLeading: CGFloat = 16
    static let groupBottom: CGFloat = 8
    static let groupTrailing: CGFloat = 16
    static let groupCount = 3
    static let zero = 0
}

class FavoriteViewController: UIViewController {

    enum Route: String {
        case details
    }

    // MARK: - Outlets
    @IBOutlet private weak var favoriteGifCollectionView: UICollectionView!
    @IBOutlet private weak var emptyLabel: UILabel!

    // MARK: - Properties
    var router: FavoriteRouter?
    var viewModel: FavoriteViewModel? {
        willSet { viewModel?.viewDelegate = nil }
        didSet { viewModel?.viewDelegate = self }
    }

    private var createLayout: UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(NumbersResources.itemWidthDimension),
                                              heightDimension: .fractionalHeight(NumbersResources.itemHeightDimension))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        item.contentInsets = .init(top: NumbersResources.itemTop,
                                   leading: NumbersResources.itemLeading,
                                   bottom: NumbersResources.itemBottom,
                                   trailing: NumbersResources.itemTrailing)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(NumbersResources.groupWidthDimension),
                                               heightDimension: .fractionalWidth(NumbersResources.groupHeightDimension))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitem: item,
                                                       count: NumbersResources.groupCount)

        group.contentInsets = .init(top: NumbersResources.groupTop,
                                    leading: NumbersResources.groupLeading,
                                    bottom: NumbersResources.groupBottom,
                                    trailing: NumbersResources.groupTrailing)

        let section = NSCollectionLayoutSection(group: group)

        return UICollectionViewCompositionalLayout(section: section)
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel?.getFavoriteGif()
        setupUI()
    }

    // MARK: - UI Methods
    private func setupUI() {
        guard let viewModel else { return }

        tabBarController?.delegate = self
        favoriteGifCollectionView.collectionViewLayout = createLayout
        emptyLabel.isHidden = viewModel.gifData.isEmpty ? false : true
        favoriteGifCollectionView.isScrollEnabled = viewModel.gifData.isEmpty ? false : true
    }

    private func updateUI() {
        guard let viewModel else { return }

        viewModel.removeAllGifData()
        viewModel.getFavoriteGif()
        emptyLabel.isHidden = viewModel.gifData.isEmpty ? false : true
        favoriteGifCollectionView.isScrollEnabled = viewModel.gifData.isEmpty ? false : true
    }
}

// MARK: - UICollectionViewDataSource
extension FavoriteViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        guard let viewModel = viewModel else { return NumbersResources.zero }

        return viewModel.gifData.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let viewModel = viewModel else { return UICollectionViewCell() }

        let gifCell: FavoriteGifCollectionViewCell = collectionView.dequeueCell(for: indexPath)
        let previewGifData = viewModel.gifData[indexPath.item].previewGifData
        let gifTitle = viewModel.gifData[indexPath.item].title

        gifCell.configure(with: previewGifData, gifTitle)

        return gifCell
    }
}

// MARK: - UICollectionViewDelegate
extension FavoriteViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        guard let viewModel = viewModel else { return }

        let gifData = viewModel.gifData[indexPath.item]
        router?.route(to: Route.details.rawValue, from: self, parameters: gifData)
    }
}

// MARK: - FavoriteViewModelDelegate
extension FavoriteViewController: FavoriteViewModelDelegate {

    func didGetFavoriteGif() {
        favoriteGifCollectionView.reloadData()
    }
}

// MARK: - UITabBarControllerDelegate
extension FavoriteViewController: UITabBarControllerDelegate {

    func tabBarController(_ tabBarController: UITabBarController,
                          didSelect viewController: UIViewController) {
        guard tabBarController.selectedIndex == TabBarControllers.favorite.rawValue else { return }

        updateUI()
    }
}

// MARK: - DetailsViewControllerDelegate
extension FavoriteViewController: DetailsViewControllerDelegate {

    func didDeleteFavoriteGif() {
        updateUI()
    }
}

// MARK: - TabBarItemController
extension FavoriteViewController: TabBarItemController {

    func scrollToTop() {
        let contentOffset = CGPoint(x: Double(NumbersResources.zero),
                                    y: -favoriteGifCollectionView.contentInset.top - view.safeAreaInsets.top)
        favoriteGifCollectionView.setContentOffset(contentOffset, animated: true)
    }
}
