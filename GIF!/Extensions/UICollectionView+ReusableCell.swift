//
//  UICollectionView+ReusableCell.swift
//  GIF!
//
//  Created by Arnold Mir on 29.01.23.
//

import UIKit

extension UICollectionView {

    func dequeueCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.identifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.identifier)")
        }
        return cell
    }
}
