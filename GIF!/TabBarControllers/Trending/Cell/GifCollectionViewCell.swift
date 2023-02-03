//
//  GifCollectionViewCell.swift
//  GIF!
//
//  Created by Arnold Mir on 27.01.23.
//

import UIKit

private enum StringResources {
    static let gifTitle = "GIF"
}

class GifCollectionViewCell: UICollectionViewCell {

    // MARK: - Outlets
    @IBOutlet private weak var gifImageView: UIImageView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var gifTitleLabel: UILabel!

    // MARK: - Life Cycle
    override func prepareForReuse() {
        super.prepareForReuse()

        gifImageView?.image = nil
        activityIndicator.startAnimating()
    }

    // MARK: - Configure
    func configure(with gifURL: URL?, _ title: String?) {
        gifTitleLabel.text = title ?? StringResources.gifTitle
        UIImage.gifImageWithURL(gifURL) { [weak self] image, _ in
            DispatchQueue.main.async {
                self?.gifImageView.image = image
                self?.activityIndicator.stopAnimating()
            }
        }
    }
}
