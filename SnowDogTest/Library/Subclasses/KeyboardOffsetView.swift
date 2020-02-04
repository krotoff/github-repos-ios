//
//  KeyboardOffsetView.swift
//  SnowDogTest
//
//  Created by Andrew Krotov on 03.02.2020.
//  Copyright © 2020 Andrew Krotov. All rights reserved.
//

import UIKit

public final class KeyboardOffsetView: UIView {
    
    // MARK: - Private properties
    
    private(set) lazy var heightConstraint: NSLayoutConstraint = {
        return heightAnchor.constraint(equalToConstant: 0)
    }()
    
    // MARK: - Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    // MARK: - Private methods
    
    private func initialize() {
        isHidden = true
        heightConstraint.isActive = true
        
        let center = NotificationCenter.default
        let selector = #selector(keyboardNotification)
        center.addObserver(self, selector: selector, name: UIResponder.keyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: selector, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? .zero
        let duration: TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let animationCurve = UIView.AnimationOptions(rawValue: animationCurveRaw)
        
        let endHeight = UIScreen.main.bounds.height > endFrame.origin.y ? endFrame.height : 0
  
        heightConstraint.constant = endHeight
        UIView.animate(withDuration: duration, delay: 0, options: animationCurve, animations: { self.superview?.layoutIfNeeded() })
    }
}
