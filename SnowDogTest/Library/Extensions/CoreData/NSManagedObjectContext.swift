//
//  NSManagedObjectContext.swift
//  SnowDogTest
//
//  Created by Andrew Krotov on 03.02.2020.
//  Copyright © 2020 Andrew Krotov. All rights reserved.
//

import CoreData

public extension NSManagedObjectContext {
    
    // MARK: - Public methods
    
    func saveContextChanges() {
        if hasChanges {
            do {
                try save()
            } catch {
                print("#ERR Could not saveContextChanges", error)
            }
        }
    }
    
    func fetch<T: NSManagedObject>() -> T? {
        return fetch(predicate: nil)
    }
    
    func fetch<T: NSManagedObject>(key: String, value: CVarArg) -> T? {
        let formatString = "\(key) == %@"
        
        return fetch(predicate: NSPredicate(format: formatString, value))
    }
    
    func fetchGroup<T: NSManagedObject>(key: String, value: CVarArg) -> [T] {
        let formatString = "\(key) in %@"
        
        return fetchGroup(predicate: NSPredicate(format: formatString, value))
    }
    
    func fetchGroup<T: NSManagedObject>(predicate: NSPredicate?) -> [T] {
        let fetchRequest = NSFetchRequest<T>(entityName: String(describing: T.self))
        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }
        
        do {
            return try fetch(fetchRequest)
        } catch {
            print("#ERR Could not fetch group", String(describing: T.self), error)
        }
        
        return []
    }
    
    func fetch<T: NSManagedObject>(predicate: NSPredicate?) -> T? {
        let fetchRequest = NSFetchRequest<T>(entityName: String(describing: T.self))
        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }
        
        do {
            return try fetch(fetchRequest).first
        } catch {
            print("#ERR Could not fetch", String(describing: T.self), error)
        }
        
        return nil
    }
}
