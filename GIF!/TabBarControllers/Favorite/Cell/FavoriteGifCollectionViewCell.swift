//
//  FavoriteGifCollectionViewCell.swift
//  GIF!
//
//  Created by Arnold Mir on 31.01.23.
//

import UIKit

private enum StringResources {
    static let gifTitle = "GIF"
}

class FavoriteGifCollectionViewCell: UICollectionViewCell {

    // MARK: - Outlets
    @IBOutlet private weak var gifImageView: UIImageView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var gifTitleLabel: UILabel!

    // MARK: - Configure
    func configure(with data: Data?, _ title: String?) {
        guard let data else { return }

        gifTitleLabel.text = title ?? StringResources.gifTitle
        gifImageView.image = UIImage.gifImageWithData(data)
        activityIndicator.stopAnimating()
    }
}
