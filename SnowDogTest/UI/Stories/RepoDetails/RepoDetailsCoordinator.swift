//
//  RepoDetailsCoordinator.swift
//  SnowDogTest
//
//  Created by Andrew Krotov on 03.02.2020.
//  Copyright © 2020 Andrew Krotov. All rights reserved.
//

import UIKit

internal final class RepoDetailsCoordinator: Coordinator {

    // MARK: - Private properties
    
    private let _navigationController: UINavigationController
    private let _repo: Repo
    private let _repoService: RepoService

    // MARK: - Initialization
    
    internal init(navigationController: UINavigationController, repo: Repo, repoService: RepoService) {
        self._navigationController = navigationController
        self._repo = repo
        self._repoService = repoService
    }
    
    // MARK: - Coordinator methods

    internal override func start() {
        let viewController = RepoDetailsViewController()
        
        viewController.onCompleted = { [weak self] in
            self?.onCompleted()
        }
        
        viewController.configure(with: _repo)
        
        _navigationController.pushViewController(viewController, animated: true)
    }
}

