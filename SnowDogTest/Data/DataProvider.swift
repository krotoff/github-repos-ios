//
//  DataProvider.swift
//  SnowDogTest
//
//  Created by Andrew Krotov on 03.02.2020.
//  Copyright © 2020 Andrew Krotov. All rights reserved.
//

import Foundation

internal final class DataProvider {
    
    // MARK: - Private properties
    
    private let _baseURL: URL
    private let _clientID: String
    private let _clientSecret: String
    
    // MARK: - Initialization
    
    init(baseURL: URL, clientID: String, clientSecret: String) {
        _baseURL = baseURL
        _clientID = clientID
        _clientSecret = clientSecret
    }
    
    // MARK: - Internal properties
    
    internal func coreData() -> CoreDataGateway {
        return .init()
    }
    
    internal func network() -> NetworkGateway {
        return .init(baseURL: _baseURL, clientID: _clientID, clientSecret: _clientSecret, keychain: keychain())
    }
    
    internal func projectFiles() -> ProjectFilesGateway {
        return .init()
    }
    
    // MARK: - Private properties
    
    private func keychain() -> KeychainGateway {
        return .init()
    }
}

