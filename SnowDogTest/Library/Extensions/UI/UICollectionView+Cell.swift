//
//  UICollectionView+Cell.swift
//  SnowDogTest
//
//  Created by Andrew Krotov on 03.02.2020.
//  Copyright © 2020 Andrew Krotov. All rights reserved.
//

import UIKit

public extension UICollectionView {
    
    // MARK: - Registering
    
    func register(nibCellClass: UICollectionViewCell.Type, bundle: Bundle? = nil) {
        register(.init(nibName: nibCellClass.reuseIdentifier, bundle: bundle), forCellWithReuseIdentifier: nibCellClass.reuseIdentifier)
    }
    
    // MARK: - Dequeuing
    
    func dequeue<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }
}

public extension UICollectionViewCell {
    
    // MARK: - Public properties
    
    static var reuseIdentifier: String { return String(describing: self) }
}
