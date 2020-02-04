//
//  RepoCell.swift
//  SnowDogTest
//
//  Created by Andrew Krotov on 03.02.2020.
//  Copyright © 2020 Andrew Krotov. All rights reserved.
//

import UIKit

internal final class RepoCell: UICollectionViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var starsLabel: UILabel!
    @IBOutlet private weak var languageLabel: UILabel!
    @IBOutlet private weak var languageColorView: RoundedView!
    @IBOutlet private weak var backgroundColorView: UIView!
    
    // MARK: - Private properties
    
    @IBInspectable private var _bounceScale: CGFloat = 0.95
    private var _defaultShadowOpacity = Float()
    
    // MARK: - Initialization
    
    internal override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    internal required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        initialize()
    }
    
    // MARK: - View lifecycle
    
    internal override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColorView.layer.masksToBounds = true
        backgroundColorView.layer.cornerRadius = 8
        backgroundColorView.backgroundColor = .white
        
        [titleLabel, languageLabel, starsLabel].forEach { $0.textColor = UIColor.black.withAlphaComponent(0.7) }
    }
    
    // MARK: - Internal methods
    
    internal func configure(with repo: Repo, languageColor: String?) {
        titleLabel.text = repo.name
        starsLabel.text = String(repo.stars)
        
        if let language = repo.language {
            languageLabel.text = language
            languageColorView.backgroundColor = languageColor.map { UIColor(hexString: $0) } ?? .darkGray
        } else {
            languageLabel.text = ""
            languageColorView.backgroundColor = .clear
        }
    }
    
    // MARK: - Private methods
    
    private func initialize() {
        clipsToBounds = false
        
        applyShadow()
        _defaultShadowOpacity = layer.shadowOpacity
    }
    
    // MARK: - Touch handling
    
    internal override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        animateScaling(isBounced: true)
    }
    
    internal override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        animateScaling(isBounced: false)
    }
    
    internal override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        animateScaling(isBounced: false)
    }
    
    // MARK: - Animation
    
    private func animateScaling(isBounced: Bool) {
        let scaleValue = isBounced ? _bounceScale : 1
        let shadowOpacity = isBounced ? 0.1 : _defaultShadowOpacity
        
        let timingParams = UISpringTimingParameters(damping: 0.4, response: 0.2)
        let animator = UIViewPropertyAnimator(duration: 0, timingParameters: timingParams)
        
        animator.addAnimations {
            self.transform = CGAffineTransform(scaleX: scaleValue, y: scaleValue)
            
            guard self.layer.shadowOpacity != shadowOpacity else { return }
            
            self.layer.shadowOpacity = shadowOpacity
        }
        
        animator.isInterruptible = true
        animator.startAnimation()
    }
}

internal final class RoundedView: UIView {
    
    // MARK: - View lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = bounds.height / 2
    }
}
