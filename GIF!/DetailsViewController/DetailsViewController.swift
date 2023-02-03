//
//  DetailsViewController.swift
//  GIF!
//
//  Created by Arnold Mir on 29.01.23.
//

import UIKit

protocol DetailsViewControllerDelegate: AnyObject {
    func didDeleteFavoriteGif()
}

private enum StringResources {
    static let favoritesButtonFavoritTitle = "Remove from favorites"
    static let favoritesButtonFavoritImage = "heart.slash.fill"
    static let favoritesButtonTitle = "Add to favorites"
    static let favoritesButtonImage = "heart.fill"
    static let authorizationPopUpTitle = "Allow access to your photos"
    static let authorizationPopUpMessage = "This will allow you to save your favorite GIF"
    static let authorizationPopUpNowAction = "Not Now"
    static let authorizationPopUpSettingsAction = "Open Settings"
    static let successSavePopUpTitle = "Saved"
    static let successSavePopUpMessage = "GIF saved to your photo gallery"
    static let errorSavePopUpTitle = "OOPS"
    static let errorSavePopUpMessage = "Something went wrong"
    static let favoritesSuccessSavePopUpTitle = "Added"
    static let favoritesSuccessSavePopUpMessage = "GIF added to favorites"
}

private enum NumbersResources {
    static let index = 6.5
}

class DetailsViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet private weak var bottomButtonConstraint: NSLayoutConstraint!
    @IBOutlet private weak var gifImageView: UIImageView!
    @IBOutlet private weak var favoritesButton: UIButton!
    @IBOutlet private weak var saveButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    // MARK: - Properties
    var viewModel: DetailsViewModel?
    weak var delegate: DetailsViewControllerDelegate?

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        bottomButtonConstraint.constant = view.frame.height / NumbersResources.index
    }

    // MARK: - UI Methods
    private func setupUI() {
        viewModel?.loadGif(completion: { [weak self] image in
            DispatchQueue.main.async {
                self?.gifImageView.image = image
                self?.activityIndicator.stopAnimating()
                self?.configureButtons(isEnable: true)
            }
        })
        titleLabel.text = viewModel?.getGifTitle()
        configureFavoritesButton()
    }

    private func configureFavoritesButton() {
        guard let viewModel else { return }

        if viewModel.isFavoriteGif() {
            favoritesButton.setTitle(StringResources.favoritesButtonFavoritTitle, for: .normal)
            favoritesButton.setImage(UIImage(systemName: StringResources.favoritesButtonFavoritImage), for: .normal)
        } else {
            favoritesButton.setTitle(StringResources.favoritesButtonTitle, for: .normal)
            favoritesButton.setImage(UIImage(systemName: StringResources.favoritesButtonImage), for: .normal)
        }
    }

    private func createAuthorizationPopUp() {
        let alert = UIAlertController(title: StringResources.authorizationPopUpTitle,
                                      message: StringResources.authorizationPopUpMessage,
                                      preferredStyle: .alert)

        let notNowAction = UIAlertAction(title: StringResources.authorizationPopUpNowAction,
                                         style: .cancel,
                                         handler: nil)
        alert.addAction(notNowAction)

        let openSettingsAction = UIAlertAction(title: StringResources.authorizationPopUpSettingsAction,
                                               style: .default) { [weak self] _ in
            self?.viewModel?.goToAppPrivacySettings()
        }
        alert.addAction(openSettingsAction)

        present(alert, animated: true, completion: nil)
    }

    private func configureButtons(isEnable: Bool) {
        saveButton.isEnabled = isEnable
        saveButton.alpha = isEnable ? 1 : 0.3
        favoritesButton.isEnabled = isEnable
        favoritesButton.alpha = isEnable ? 1 : 0.3
    }

    // MARK: - Helper Methods
    private func createSavePopUp(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        present(alert, animated: true, completion: nil)

        let delay = DispatchTime.now() + 1.5
        DispatchQueue.main.asyncAfter(deadline: delay) {
            alert.dismiss(animated: true, completion: nil)
        }
    }

    // MARK: - Actions
    @IBAction private func saveButtonPressed(_ sender: Any) {
        viewModel?.requestAuthorizationStatus(authorizationCompletion: { [weak self] in
            DispatchQueue.main.async {
                self?.createAuthorizationPopUp()
            }
        }, saveCompletion: { [weak self] success in
            if success {
                DispatchQueue.main.async {
                    self?.createSavePopUp(title: StringResources.successSavePopUpTitle,
                                          message: StringResources.successSavePopUpMessage )
                }
            } else {
                DispatchQueue.main.async {
                    self?.createSavePopUp(title: StringResources.errorSavePopUpTitle,
                                          message: StringResources.errorSavePopUpMessage)
                }
            }
        })
    }

    @IBAction private func favoritesButtonPressed(_ sender: UIButton) {
        guard let viewModel else { return }

        if viewModel.isFavoriteGif() {
            viewModel.deleteFavoriteGif()
            delegate?.didDeleteFavoriteGif()
            dismiss(animated: true)
        } else if let gifList = viewModel.gifList {
            FileManager.saveGifToFiles(with: gifList) { [weak self] in
                self?.createSavePopUp(title: StringResources.favoritesSuccessSavePopUpTitle,
                                      message: StringResources.favoritesSuccessSavePopUpMessage )
            } errorCompletion: { [weak self] in
                self?.createSavePopUp(title: StringResources.errorSavePopUpTitle,
                                      message: StringResources.errorSavePopUpMessage)
            }
            configureFavoritesButton()
        }
    }
}
