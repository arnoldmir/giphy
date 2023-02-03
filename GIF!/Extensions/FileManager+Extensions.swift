//
//  FileManager+Extensions.swift
//  GIF!
//
//  Created by Arnold Mir on 31.01.23.
//

import Foundation

private enum StringResources {
    static let folderName = "GIFs"
    static let empty = ""
}

extension FileManager {

    static var gifDirectoryUrl: URL {
        return FileManager.default.urls(for: .documentDirectory,
                                        in: .userDomainMask)[0].appendingPathComponent(StringResources.folderName)
    }

    static func saveGifToFiles(with gifList: GifList, successCompletion: () -> Void, errorCompletion: () -> Void) {
        guard let gifData = try? JSONEncoder().encode(gifList) else { return }

        if !FileManager.default.fileExists(atPath: FileManager.gifDirectoryUrl.path) {
            try? FileManager.default.createDirectory(atPath: FileManager.gifDirectoryUrl.path,
                                                     withIntermediateDirectories: true)
        }
        let fileUrl = FileManager.gifDirectoryUrl.appendingPathComponent(gifList.id ?? StringResources.empty)
        if FileManager.default.createFile(atPath: fileUrl.path,
                                          contents: gifData, attributes: [.creationDate: Date()]) {
            successCompletion()
        } else {
            errorCompletion()
        }
    }

    static func downloadGifsFromFiles() -> [GifList] {
        var gifData: [GifList] = []
        let directoryContents = try? FileManager.default.contentsOfDirectory(atPath: FileManager.gifDirectoryUrl.path)
        directoryContents?.forEach({ fileName in
            let fileUrl = FileManager.gifDirectoryUrl.appendingPathComponent(fileName)
            if let data = FileManager.default.contents(atPath: fileUrl.path) {
                do {
                    let gif = try JSONDecoder().decode(GifList.self, from: data)
                    gifData.append(gif)
                } catch {
                    print(error)
                }
            }
            print(gifData)
        })

        return gifData
    }

    static func deleteGifFromFiles(with gifId: String?) {
        guard let gifId else { return }

        let fileUrl = FileManager.gifDirectoryUrl.appendingPathComponent(gifId)
        try? FileManager.default.removeItem(at: fileUrl)
    }
}
