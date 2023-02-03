//
//  FavoriteGifsModel.swift
//  GIF!
//
//  Created by Arnold Mir on 30.01.23.
//

import Foundation

struct GifList: Codable {

    var id: String?
    var title: String?
    var previewGifData: Data?
    var originalGifData: Data?

    private enum CodingKeys: String, CodingKey {
        case id, title, previewGifData, originalGifData
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(previewGifData, forKey: .previewGifData)
        try container.encode(originalGifData, forKey: .originalGifData)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        previewGifData = try container.decode(Data.self, forKey: .previewGifData)
        originalGifData = try container.decode(Data.self, forKey: .originalGifData)
    }

    init(id: String?, title: String?, previewGifData: Data? = nil, originalGifData: Data? = nil) {
        self.id = id
        self.title = title
        self.previewGifData = previewGifData
        self.originalGifData = originalGifData
    }
}

struct TrendingGifList: Codable {

    var trendingGifList: [TrendingGif]

    private enum CodingKeys: String, CodingKey {
        case trendingGifList = "data"
    }
}

struct TrendingGif: Codable {

    var id: String
    var title: String
    var gif: GifSize

    private enum CodingKeys: String, CodingKey {
        case id, title
        case gif = "images"
    }
}

struct GifSize: Codable {

    var previewGif: GifUrl
    var originalGif: GifUrl

    private enum CodingKeys: String, CodingKey {
        case previewGif = "preview_gif"
        case originalGif = "original"
    }
}

struct GifUrl: Codable {

    var gifUrl: String

    private enum CodingKeys: String, CodingKey {
        case gifUrl = "url"
    }
}
