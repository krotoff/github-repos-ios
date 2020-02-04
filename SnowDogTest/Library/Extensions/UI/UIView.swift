//
//  UIView.swift
//  SnowDogTest
//
//  Created by Andrew Krotov on 03.02.2020.
//  Copyright © 2020 Andrew Krotov. All rights reserved.
//

import UIKit

public extension UIView {

// MARK: - Public methods

    func applyShadow(color: UIColor = .black, offset: CGSize = .init(width: 0, height: 4), opacity: Float = 0.25, radius: CGFloat = 4) {
        layer.shadowColor = color.cgColor
        layer.shadowOffset = offset
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
    }
}
