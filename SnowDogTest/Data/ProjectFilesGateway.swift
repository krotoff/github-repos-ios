//
//  ProjectFilesGateway.swift
//  SnowDogTest
//
//  Created by Andrew Krotov on 03.02.2020.
//  Copyright © 2020 Andrew Krotov. All rights reserved.
//

import Foundation

internal final class ProjectFilesGateway {
    
    // MARK: - Internal properties
    
    internal var colors: [String: String]!
    
    // MARK: - Private properties
    
    private let _decoder = JSONDecoder()
    
    // MARK: - Internal methods
    
    internal func fetchColors() {
        guard let filePath = Bundle.main.path(forResource: "colors", ofType: "json") else {
            print("#ERR no data in JSON")
            return
        }
        
        struct Color: Codable {
            var color: String?
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
            colors = try JSONDecoder().decode([String: Color].self, from: data)
                .compactMapValues { $0.color }
        } catch {
            print("#ERR Could not parse colors.json", error)
        }
    }
}
