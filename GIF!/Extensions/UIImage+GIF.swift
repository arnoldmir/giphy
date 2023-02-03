//
//  UIImage+GIF.swift
//  GIF!
//
//  Created by Arnold Mir on 30.01.23.
//

import UIKit

extension UIImage {

    public class func gifImageWithData(_ data: Data) -> UIImage? {
        return createAnimatedImage(data: data)
    }

    public class func gifImageWithURL(_ gifUrl: URL?, completion: @escaping (UIImage?, Data?) -> Void) {
        guard let url = gifUrl else { return }

        DispatchQueue.global().async {
            guard let imageData = try? Data(contentsOf: url) else { return }

            completion(gifImageWithData(imageData), imageData)
        }
    }

    private static func createAnimatedImage(data: Data) -> UIImage? {
        guard let source  = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }

        var frames = [UIImage]()
        let count = CGImageSourceGetCount(source)
        let delaySeconds = delayForImageAtIndex(0, source: source)
        let duration = Double(count) * delaySeconds

        for index in 0..<count {
            if let image = CGImageSourceCreateImageAtIndex(source, index, nil) {
                frames.append(UIImage(cgImage: image))
            }
        }

        return UIImage.animatedImage(with: frames, duration: duration)
    }

    private static func delayForImageAtIndex(_ index: Int, source: CGImageSource) -> Double {
        var delay = 0.1

        if let gifProperties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as Dictionary? {
            let kCGImagePropertyGIFDictionary = kCGImagePropertyGIFDictionary as NSString
            let kCGImagePropertyGIFDelayTime = kCGImagePropertyGIFDelayTime as NSString
            if let delayTime = gifProperties[kCGImagePropertyGIFDictionary]?[kCGImagePropertyGIFDelayTime] {
                delay = Double(truncating: delayTime as? NSNumber ?? 0.1)
            }
        }
        return delay
    }
}
