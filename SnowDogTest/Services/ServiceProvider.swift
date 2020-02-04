//
//  ServiceProvider.swift
//  SnowDogTest
//
//  Created by Andrew Krotov on 03.02.2020.
//  Copyright © 2020 Andrew Krotov. All rights reserved.
//

import Foundation

internal final class ServiceProvider {
    
    private let _data: DataProvider
    
    init(data: DataProvider) {
        _data = data
    }
    
    // MARK: - Internal properties
    
    internal func repo() -> RepoService {
        return .init(networkClient: _data.network(), storage: _data.coreData(), projectFiles: _data.projectFiles())
    }
}
