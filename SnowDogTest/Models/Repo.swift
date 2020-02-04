//
//  Repo.swift
//  SnowDogTest
//
//  Created by Andrew Krotov on 03.02.2020.
//  Copyright © 2020 Andrew Krotov. All rights reserved.
//

import Foundation

internal final class Repo: Codable {
    
    // MARK: - Internal properties
    
    internal let id: Int
    internal var name: String
    internal var language: String?
    internal var url: String
    internal var stars: Int
    internal var watchers: Int
    internal var forks: Int?
    
    // MARK: - Initialization
    
    internal init(managed: ManagedRepo) {
        name = managed.name ?? ""
        id = Int(managed.id)
        language = managed.language
        url = managed.url ?? ""
        stars = Int(managed.stars)
        watchers = Int(managed.watchers)
        forks = Int(managed.forks)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case language
        case stars = "stargazers_count"
        case watchers = "watchers_count"
        case forks = "forks_count"
        case url = "html_url"
    }
}
