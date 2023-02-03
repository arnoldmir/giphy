//
//  FavoriteViewModel.swift
//  GIF!
//
//  Created by Arnold Mir on 31.01.23.
//

import Foundation

protocol FavoriteViewModelDelegate: AnyObject {
    func didGetFavoriteGif()
}

class FavoriteViewModel: NSObject {

    // MARK: - Properties
    weak var viewDelegate: FavoriteViewModelDelegate?
    private(set) var gifData: [GifList] = []

    // MARK: - Helper Methods
    func getFavoriteGif() {
        gifData.append(contentsOf: FileManager.downloadGifsFromFiles())
        viewDelegate?.didGetFavoriteGif()
    }

    func removeAllGifData() {
        gifData.removeAll()
    }
}
