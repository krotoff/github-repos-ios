//
//  ManagedRepo.swift
//  SnowDogTest
//
//  Created by Andrew Krotov on 03.02.2020.
//  Copyright © 2020 Andrew Krotov. All rights reserved.
//

import Foundation
import CoreData

@objc(ManagedRepo)
internal final class ManagedRepo: NSManagedObject {
    
    // MARK: - Initialization
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: NSEntityDescription.entity(forEntityName: String(describing: Self.self), in: context!)!, insertInto: context)
    }
    
    internal init(plain: Repo, context: NSManagedObjectContext) {
        super.init(entity: NSEntityDescription.entity(forEntityName: String(describing: Self.self), in: context)!, insertInto: context)
        
        id = Int64(plain.id)
        name = plain.name
        language = plain.language
        stars = Int64(plain.stars)
        watchers = Int64(plain.watchers)
        forks = plain.forks.map(Int64.init) ?? 0
        url = plain.url
    }
    
    // MARK: - Internal methods
    
    internal func update(with plain: Repo) {
        name = plain.name
        language = plain.language
        stars = Int64(plain.stars)
        watchers = Int64(plain.watchers)
        forks = plain.forks.map(Int64.init) ?? 0
        url = plain.url
    }
}


