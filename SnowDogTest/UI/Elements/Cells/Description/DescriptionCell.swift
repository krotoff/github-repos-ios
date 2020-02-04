//
//  DescriptionCell.swift
//  SnowDogTest
//
//  Created by Andrew Krotov on 04.02.2020.
//  Copyright © 2020 Andrew Krotov. All rights reserved.
//

import UIKit

internal final class DescriptionCell: UICollectionViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: - Internal methods
    
    internal func configure(text: String, imageName: String?) {
        titleLabel.text = text
        imageView.isHidden = imageName == nil
        if let imageName = imageName {
            imageView.image = UIImage(named: imageName)
        }
    }
}
