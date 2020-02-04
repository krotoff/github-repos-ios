//
//  AppCoordinator.swift
//  SnowDogTest
//
//  Created by Andrew Krotov on 03.02.2020.
//  Copyright © 2020 Andrew Krotov. All rights reserved.
//

import UIKit
import WebKit

internal final class AppCoordinator: Coordinator {

    // MARK: - Private properties
    
    private let window: UIWindow
    
    private let _dataProvider = DataProvider(
        baseURL: URL(string: "https://api.github.com")!,
        clientID: "902bdcc1161ba300df92",
        clientSecret: "5bbb634141a0f136bbd2b12dbace5ae1e28cac39"
    )
    private lazy var _serviceProvider = ServiceProvider(data: _dataProvider)
    
    private var _authorizeWithCode: ((String) -> ())!

    // MARK: - Initialization
    
    internal init(window: UIWindow) {
        self.window = window
        
        super.init()
    }

    // MARK: - Coordinator methods
    
    internal override func start() {
        let navigationController = UINavigationController()
        navigationController.view.backgroundColor = .white
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black.withAlphaComponent(0.7)]
        navigationController.navigationBar.tintColor = .white
        
        let network = _dataProvider.network()
        
        if network.isAuthorized() {
            startMainFlow(with: navigationController)
        }
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        if !network.isAuthorized() {
            let url = network.authURL()
            let webView = WKWebView()
            
            let vc = UIViewController()
            vc.view = webView
            
            _authorizeWithCode = { [unowned self] code in
                network.authorize(with: code) { (result) in
                    switch result {
                    case .success:
                        navigationController.dismiss(animated: true) {
                            self.startMainFlow(with: navigationController)
                        }
                    case let .failure(error):
                        let alertController = UIAlertController(title: nil, message: "\(error)", preferredStyle: .alert)
                        let cancelAction = UIAlertAction(title: "OK", style: .cancel)
                        alertController.addAction(cancelAction)
                        
                        vc.present(alertController, animated: true)
                    }
                }
            }
            
            navigationController.present(vc, animated: true)
            webView.load(URLRequest(url: url))
            webView.allowsBackForwardNavigationGestures = true
            webView.addObserver(self, forKeyPath: "URL", options: .new, context: nil)
        }
    }
    
    private func startMainFlow(with navigationController: UINavigationController) {
        let myCoordinator = ReposCoordinator(navigationController: navigationController, repoService: _serviceProvider.repo())

        store(myCoordinator)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.url), let webView = object as? WKWebView {
            if let url = webView.url, url.absoluteString.contains("snowdog.com/test/krotov/callback"), url.absoluteString.contains("code=") {
                let code = String(url.absoluteString.split(separator: "=")[1])
                _authorizeWithCode(code)
            }
        }
    }
}
