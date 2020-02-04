//
//  ReposCoordinator.swift
//  SnowDogTest
//
//  Created by Andrew Krotov on 03.02.2020.
//  Copyright © 2020 Andrew Krotov. All rights reserved.
//

import UIKit

internal final class ReposCoordinator: Coordinator {

    // MARK: - Private properties
    
    private let _navigationController: UINavigationController
    private let _repoService: RepoService
    
    // MARK: - Initialization
    
    internal init(navigationController: UINavigationController, repoService: RepoService) {
        self._navigationController = navigationController
        self._repoService = repoService
    }

    // MARK: - Coordinator methods
    
    internal override func start() {
        let viewController = ReposViewController()
        viewController.configure(with: _repoService)
        viewController.showDetails = { [unowned self] repo in
            self.showRepoDetails(repo: repo)
        }
        
        _navigationController.pushViewController(viewController, animated: true)
    }
    
    // MARK: - Private methods
    
    private func showRepoDetails(repo: Repo) {
        let coordinator = RepoDetailsCoordinator(navigationController: _navigationController, repo: repo, repoService: _repoService)

        coordinator.onCompleted = { [unowned self] in
            self.free(coordinator)
        }

        store(coordinator)
    }
}
