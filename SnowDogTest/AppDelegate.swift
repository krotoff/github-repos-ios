//
//  AppDelegate.swift
//  SnowDogTest
//
//  Created by Andrew Krotov on 03.02.2020.
//  Copyright © 2020 Andrew Krotov. All rights reserved.
//

import UIKit

@UIApplicationMain
public class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: - Public properties
    
    public var window: UIWindow?
    
    // MARK: - Private properties
    
    private var appCoordinator : AppCoordinator!

    // MARK: - UIApplicationDelegate methods
    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow()

        let appCoordinator = AppCoordinator(window: window!)
        appCoordinator.start()
        self.appCoordinator = appCoordinator

        return true
    }
}

