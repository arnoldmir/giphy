//
//  TrendingViewModel.swift
//  GIF!
//
//  Created by Arnold Mir on 29.01.23.
//

import Foundation

private enum StringResources {
    static let baseURL = "https://api.giphy.com/v1/gifs/"
    static let trending = "trending"
    static let search = "search"
    static let apiKey = "api_key"
    static let offset = "offset"
    static let limit = "limit"
    static let searchedText = "q"
    static let language = "lang"
    static let apiKeyValue = "DOG95FqEibgoEdxYjQpH8jR38R2jRS24"
    static let limitValue = "25"
    static let languageValue = "en"
    static let methodGet = "GET"
    static let empty = ""
}

private enum NumbersResources {
    static let zero = 0
    static let pageSize = 25
    static let timeInterval = 0.5
}

protocol TrendingViewModelDelegate: AnyObject {
    func reloadData(_ viewModel: TrendingViewModel)
}

class TrendingViewModel: NSObject {

    enum RequestState: String {
        case trending
        case search
    }

    // MARK: - Properties
    weak var viewDelegate: TrendingViewModelDelegate?

    private var nextTrendingPosition: Int = NumbersResources.zero
    private var nextSearchPosition: Int = NumbersResources.zero
    private(set) var requestState: RequestState = .trending
    private(set) var searchedText: String = StringResources.empty
    private(set) var previousGifCount: Int = NumbersResources.zero
    private(set) var gifList: [TrendingGif] = [] {
        didSet {
            viewDelegate?.reloadData(self)
        }
    }

    // MARK: - Helper Methods

    func changeRequestState(state: RequestState, text: String? = nil) {
        gifList.removeAll()
        requestState = state
        nextTrendingPosition = NumbersResources.zero
        nextSearchPosition = NumbersResources.zero
        searchedText = text ?? StringResources.empty
        switch state {
        case .trending:
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(search(_:)), object: nil)
            downloadGifList(with: requestState)
        case .search:
            makeSearchGif(with: searchedText)
        }
    }

    func getGifTitle(index: Int) -> String? {
        return index < gifList.count ? gifList[index].title : nil
    }

    func getPreviewGifUrl(index: Int) -> URL? {
        return index < gifList.count ? URL(string: gifList[index].gif.previewGif.gifUrl) : nil
    }

    func getOriginalGifUrl(index: Int) -> URL? {
        return index < gifList.count ? URL(string: gifList[index].gif.originalGif.gifUrl) : nil
    }

    func getGifId(index: Int) -> String? {
        return index < gifList.count ? gifList[index].id : nil
    }

    func getPreviewGifData(index: Int, completion: @escaping (Data?) -> Void) {
        guard let url = URL(string: gifList[index].gif.previewGif.gifUrl) else { return }

        DispatchQueue.global().async {
            let imageData = try? Data(contentsOf: url)
            completion(imageData)
        }
    }

    func createIndexPaths(gifCount: Int, nextPosition: Int ) -> [IndexPath] {
        guard gifCount < nextPosition else { return [] }

        var next: Int {
            guard nextPosition == -1 else { return nextPosition }
            return NumbersResources.zero
        }

        let indexPaths = Array(gifCount...next).map { IndexPath(item: $0, section: NumbersResources.zero) }

        return indexPaths
    }

    func downloadGifList(with state: RequestState, _ searchedText: String? = nil) {
        var components: URLComponents?
        switch state {
        case .trending:
            components = URLComponents(string: StringResources.baseURL + StringResources.trending)

            let queryItems = [URLQueryItem(name: StringResources.apiKey, value: StringResources.apiKeyValue),
                              URLQueryItem(name: StringResources.offset, value: String(nextTrendingPosition)),
                              URLQueryItem(name: StringResources.limit, value: StringResources.limitValue)]
            components?.queryItems = queryItems
        case .search:
            guard let searchedText else { return }
            components = URLComponents(string: StringResources.baseURL + StringResources.search)

            let queryItems = [URLQueryItem(name: StringResources.apiKey, value: StringResources.apiKeyValue),
                              URLQueryItem(name: StringResources.offset, value: String(nextSearchPosition)),
                              URLQueryItem(name: StringResources.searchedText, value: searchedText),
                              URLQueryItem(name: StringResources.language, value: StringResources.languageValue),
                              URLQueryItem(name: StringResources.limit, value: StringResources.limitValue)]
            components?.queryItems = queryItems
        }

        guard let url = components?.url else { return }
        var request = URLRequest(url: url)
        print(url)
        request.httpMethod = StringResources.methodGet
        switch state {
        case .trending:
            download(with: request, nextTrendingPosition)
            nextTrendingPosition += NumbersResources.pageSize
        case .search:
            download(with: request, nextSearchPosition)
            nextSearchPosition += NumbersResources.pageSize
        }
    }

    private func download(with request: URLRequest, _ nextPosition: Int) {
        previousGifCount = gifList.count
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, _ in
            guard let strongSelf = self else { return }
            if let data = data {
                do {
                    let trendingGifList = try JSONDecoder().decode(TrendingGifList.self, from: data)
                    if nextPosition == NumbersResources.zero {
                        strongSelf.gifList = trendingGifList.trendingGifList
                    } else {
                        strongSelf.gifList.append(contentsOf: trendingGifList.trendingGifList)
                    }
                } catch {
                    print(error)
                }
            }
        }
        task.resume()
    }

    private func makeSearchGif(with term: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        perform(#selector(search(_:)), with: term, afterDelay: TimeInterval(NumbersResources.timeInterval))
    }

    @objc private func search(_ text: String) {
        downloadGifList(with: .search, text)
    }
}
