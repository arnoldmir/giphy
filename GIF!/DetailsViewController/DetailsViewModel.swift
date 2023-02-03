//
//  DetailsViewModel.swift
//  GIF!
//
//  Created by Arnold Mir on 30.01.23.
//

import Photos
import UIKit

class DetailsViewModel: NSObject {

    enum State {
        case trending
        case favorite
    }

    // MARK: - Properties
    private(set) var gifList: GifList?
    private(set) var state: State
    private var gifUrl: URL?

    // MARK: - Init
    init(gifList: GifList? = nil, gifUrl: URL? = nil, state: State) {
        self.gifList = gifList
        self.gifUrl = gifUrl
        self.state = state
    }

    // MARK: - Helper Methods
    func getGifTitle() -> String {
        return gifList?.title ?? "GIF!"
    }

    func loadGif(completion: @escaping (UIImage?) -> Void) {
        switch state {
        case .trending:
            UIImage.gifImageWithURL(gifUrl) { [weak self] image, data in
                completion(image)
                self?.gifList?.originalGifData = data
            }
        case .favorite:
            guard let gifData = gifList?.originalGifData else { return }

            completion(UIImage.gifImageWithData(gifData))
        }
    }

    func isFavoriteGif() -> Bool {
        guard let gifId = gifList?.id else { return false}

        let gifList = FileManager.downloadGifsFromFiles()

        return gifList.contains(where: {$0.id == gifId})
    }

    func deleteFavoriteGif() {
        FileManager.deleteGifFromFiles(with: gifList?.id)
    }

    func requestAuthorizationStatus(authorizationCompletion: @escaping () -> Void,
                                    saveCompletion: @escaping (Bool) -> Void) {
        switch PHPhotoLibrary.authorizationStatus(for: .addOnly) {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { [weak self] status in
                switch status {
                case .authorized, .limited:
                    self?.saveGifToLibrary(saveCompletion: { success in
                        saveCompletion(success)
                    })
                default: authorizationCompletion()
                }
            }
        case .restricted, .denied: authorizationCompletion()
        default:
            saveGifToLibrary { success in
                saveCompletion(success)
            }
        }
    }

    func goToAppPrivacySettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else { return }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    private func saveGifToLibrary(saveCompletion: @escaping (Bool) -> Void) {
        guard let imageData = gifList?.originalGifData else { return }

        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetCreationRequest.forAsset()
            request.addResource(with: .photo, data: imageData, options: nil)
        }) { success, _ in
            if success {
                saveCompletion(success)
            }
        }
    }
}
