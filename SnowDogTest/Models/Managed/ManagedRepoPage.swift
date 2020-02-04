//
//  ManagedRepoPage.swift
//  SnowDogTest
//
//  Created by Andrew Krotov on 03.02.2020.
//  Copyright © 2020 Andrew Krotov. All rights reserved.
//

import Foundation
import CoreData

@objc(ManagedRepoPage)
internal final class ManagedRepoPage: NSManagedObject {
    
    // MARK: - Initialization
    
    internal override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: NSEntityDescription.entity(forEntityName: String(describing: Self.self), in: context!)!, insertInto: context)
    }
    
    internal init(plain: RepoPage, context: NSManagedObjectContext) {
        super.init(entity: NSEntityDescription.entity(forEntityName: String(describing: Self.self), in: context)!, insertInto: context)
        
        repos = NSOrderedSet(array: plain.repos.map { ManagedRepo(plain: $0, context: context) })
    }
}



