//
//  TrendingViewController.swift
//  GIF!
//
//  Created by Arnold Mir on 27.01.23.
//

import UIKit

private enum StringResources {
    static let placeholder = "Search"
}

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
    static let difference = 3
    static let nextPosition = 1
}

class TrendingViewController: UIViewController, UISearchControllerDelegate {

    enum Route: String {
        case details
    }

    // MARK: - Outlets
    @IBOutlet private weak var gifCollectionView: UICollectionView!
    @IBOutlet private weak var emptyLabel: UILabel!

    // MARK: - Properties
    var router: TrendingRouter?
    var viewModel: TrendingViewModel? {
        willSet { viewModel?.viewDelegate = nil }
        didSet { viewModel?.viewDelegate = self }
    }

    private lazy var tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)))
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

        setupUI()
        setupNotifications()
        viewModel?.downloadGifList(with: .trending)
    }

    // MARK: - Helper Methods
    private func setupSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.automaticallyShowsCancelButton = false
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = StringResources.placeholder
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController?.navigationItem.largeTitleDisplayMode = .automatic
        definesPresentationContext = true
    }

    private func getNextGifPage() {
        guard let viewModel else { return }

        viewModel.downloadGifList(with: viewModel.requestState, viewModel.searchedText)
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleKeyboardShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleKeyboardHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    // MARK: - UI Methods
    private func setupUI() {
        guard let viewModel else { return }

        gifCollectionView.collectionViewLayout = createLayout
        setupSearchController()
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        emptyLabel.isHidden = viewModel.gifList.isEmpty ? false : true
    }

    private func isUserInteraction(enable: Bool) {
        gifCollectionView.isUserInteractionEnabled = enable
    }

    private func setOffset() {
        let contentOffset = CGPoint(x: Double(NumbersResources.zero),
                                    y: -gifCollectionView.contentInset.top - view.safeAreaInsets.top)
        gifCollectionView.setContentOffset(contentOffset, animated: true)
    }

    // MARK: - Actions
    @objc private func viewTapped(_ sender: UITapGestureRecognizer) {
        navigationItem.searchController?.searchBar.resignFirstResponder()
    }

    @objc private func handleKeyboardShow(notification: Notification) {
        isUserInteraction(enable: false)
    }

    @objc private func handleKeyboardHide(notification: Notification) {
        isUserInteraction(enable: true)
    }
}

// MARK: - UICollectionViewDataSource
extension TrendingViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let viewModel else { return NumbersResources.zero }

        return viewModel.gifList.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let viewModel = viewModel else { return UICollectionViewCell() }

        let gifCell: GifCollectionViewCell = collectionView.dequeueCell(for: indexPath)
        let previewURL = viewModel.getPreviewGifUrl(index: indexPath.item)
        let gifTitle = viewModel.getGifTitle(index: indexPath.item)

        gifCell.configure(with: previewURL, gifTitle)

        return gifCell
    }
}

// MARK: - UICollectionViewDelegate
extension TrendingViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        guard let viewModel = viewModel else { return }

        let id = viewModel.getGifId(index: indexPath.item)
        let title = viewModel.getGifTitle(index: indexPath.item)
        var gifList = GifList(id: id, title: title)
        viewModel.getPreviewGifData(index: indexPath.item) { [weak self] data in
            guard let strongSelf = self else { return }

            gifList.previewGifData = data
            DispatchQueue.main.async {
                self?.router?.route(to: Route.details.rawValue,
                                    from: strongSelf,
                                    parameters: (gifList, viewModel.getOriginalGifUrl(index: indexPath.item)))
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let viewModel = viewModel,
              indexPath.item == viewModel.gifList.count - NumbersResources.difference else { return }

        getNextGifPage()
    }
}

// MARK: - UISearchBarDelegate
extension TrendingViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            viewModel?.changeRequestState(state: .trending)
            return
        }

        viewModel?.changeRequestState(state: .search, text: searchText)
        setOffset()
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        guard let text = searchBar.text,
              text.isEmpty else { return }

        viewModel?.changeRequestState(state: .trending)
    }
}

// MARK: - TrendingViewModelDelegate
extension TrendingViewController: TrendingViewModelDelegate {

    func reloadData(_ viewModel: TrendingViewModel) {
        guard viewModel.gifList.count != NumbersResources.zero else {
            DispatchQueue.main.async { [weak self] in
                self?.emptyLabel.isHidden = viewModel.gifList.isEmpty ? false : true
                self?.gifCollectionView.reloadData()
            }
            return
        }

        let path = viewModel.createIndexPaths(gifCount: viewModel.previousGifCount,
                                              nextPosition: viewModel.gifList.count - NumbersResources.nextPosition)
        guard !path.isEmpty else { return }

        DispatchQueue.main.async { [weak self] in
            self?.gifCollectionView.performBatchUpdates({
                self?.gifCollectionView.insertItems(at: path)
                self?.gifCollectionView.reconfigureItems(at: path)
                self?.emptyLabel.isHidden = viewModel.gifList.isEmpty ? false : true
            })
        }
    }
}

extension TrendingViewController: TabBarItemController {

    func scrollToTop() {
        setOffset()
    }
}
