//
//  RepoPage.swift
//  SnowDogTest
//
//  Created by Andrew Krotov on 03.02.2020.
//  Copyright © 2020 Andrew Krotov. All rights reserved.
//

import Foundation

internal final class RepoPage: Codable {
    
    // MARK: - Internal properties
    
    internal var repos: [Repo]
    
    // MARK: - Initialization
    
    internal init() {
        repos = []
    }
    
    internal init(managed: ManagedRepoPage) {
        let managedRepos = managed.repos.map { Array($0) as! [ManagedRepo] } ?? []
        repos = managedRepos.map(Repo.init)
    }
}
