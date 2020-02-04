//
//  RepoService.swift
//  SnowDogTest
//
//  Created by Andrew Krotov on 03.02.2020.
//  Copyright © 2020 Andrew Krotov. All rights reserved.
//

internal final class RepoService {
    
    // MARK: - Internal properties
    
    internal var contextWasChanged: (() -> ())?
    internal var repoPage: RepoPage? { return _storage.fetchRepoPage() }
    
    // MARK: - Private properties
    
    private let _storage: CoreDataGateway
    private let _networkClient: NetworkGateway
    private let _projectFiles: ProjectFilesGateway
    
    // MARK: - Initialization
    
    init(networkClient: NetworkGateway, storage: CoreDataGateway, projectFiles: ProjectFilesGateway) {
        _networkClient = networkClient
        _storage = storage
        _projectFiles = projectFiles
        _storage.contextWasChanged = { [weak self] in
            self?.contextWasChanged?()
        }
        _projectFiles.fetchColors()
    }
    
    // MARK: - Internal methods
    
    internal func refreshRepoPage() {
        _networkClient.requestRepos(for: "") { [weak self] (result) in
            switch result {
            case let .success(repos):
                guard let `self` = self else { return }
                
                self._storage.updateOrCreateRepoPage(with: repos)
                
            case let .failure(error):
                print("#ERR Could not load repos", error)
            }
        }
    }
    
    internal func hexForLanguage(_ language: String?) -> String? {
        if let language = language {
            return _projectFiles.colors[language]
        } else {
            return nil
        }
    }
}
