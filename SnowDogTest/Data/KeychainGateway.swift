//
//  KeychainGateway.swift
//  SnowDogTest
//
//  Created by Andrew Krotov on 04.02.2020.
//  Copyright © 2020 Andrew Krotov. All rights reserved.
//

import Foundation

internal final class KeychainGateway {
    
    enum KeychainError: Error {
        case noPassword
        case unexpectedPasswordData
        case unexpectedItemData
        case unhandledError(status: OSStatus)
    }
    
    // MARK: - Private properties
    
    private let _service = "SnowDogTest"
    private let _account = "DefaultUser"
    private let _accessGroup: String? = nil

    // MARK: Intialization
    
    init() {}
    
    // MARK: - Internal methods
    
    internal func readPassword() throws -> String  {
        var query = keychainQuery()
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanTrue
        
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        
        guard status != errSecItemNotFound else { throw KeychainError.noPassword }
        guard status == noErr else { throw KeychainError.unhandledError(status: status) }
        
        guard let existingItem = queryResult as? [String : AnyObject],
            let passwordData = existingItem[kSecValueData as String] as? Data,
            let password = String(data: passwordData, encoding: String.Encoding.utf8)
        else {
            throw KeychainError.unexpectedPasswordData
        }
        
        return password
    }
    
    internal func savePassword(_ password: String) throws {
        let encodedPassword = password.data(using: String.Encoding.utf8)!
        
        do {
            try _ = readPassword()

            var attributesToUpdate = [String : AnyObject]()
            attributesToUpdate[kSecValueData as String] = encodedPassword as AnyObject?

            let query = keychainQuery()
            let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
            
            guard status == noErr else { throw KeychainError.unhandledError(status: status) }
        } catch KeychainError.noPassword {
            var newItem = keychainQuery()
            newItem[kSecValueData as String] = encodedPassword as AnyObject?
            
            let status = SecItemAdd(newItem as CFDictionary, nil)
            
            guard status == noErr else { throw KeychainError.unhandledError(status: status) }
        }
    }

    // MARK: - Private methods
    
    private func keychainQuery() -> [String : AnyObject] {
        var query = [String : AnyObject]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = _service as AnyObject?
        query[kSecAttrAccount as String] = _account as AnyObject?
        
        if let accessGroup = _accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup as AnyObject?
        }
        
        return query
    }
}
