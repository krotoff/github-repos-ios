//
//  CoordinatableViewController.swift
//  SnowDogTest
//
//  Created by Andrew Krotov on 03.02.2020.
//  Copyright © 2020 Andrew Krotov. All rights reserved.
//

import UIKit

public class CoordinatableViewController: UIViewController {
    
    // MARK: - Public properties
    
    public var onCompleted: (() -> ())!
    
    // MARK: - View lifecycle
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let navController = navigationController, !navController.viewControllers.contains(self) {
            onCompleted()
        } else if navigationController == nil {
            onCompleted()
        }
    }
}

