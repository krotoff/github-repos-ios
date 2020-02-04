//
//  CoreDataGateway.swift
//  SnowDogTest
//
//  Created by Andrew Krotov on 03.02.2020.
//  Copyright © 2020 Andrew Krotov. All rights reserved.
//

import CoreData

internal final class CoreDataGateway {
    
    // MARK: - Internal properties
    
    internal var contextWasChanged: (() -> ())?
    
    // MARK: - Private properties
    
    private lazy var _persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "SnowDogTest")
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                print("#ERR Could not loadPersistentStores", error)
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange),
                                               name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
                                               object: container.viewContext)
        
        return container
    }()
    
    // MARK: - Internal methods
    
    // MARK: - Fetching
    
    internal func fetchRepoPage() -> RepoPage {
        let page: ManagedRepoPage? = _persistentContainer.viewContext.fetch()
        
        if let page = page {
            return .init(managed: page)
        } else {
            return .init()
        }
    }
    
    // MARK: - Updating
    
    internal func updateOrCreateRepoPage(with newRepos: [Repo]) {
        let managedContext = _persistentContainer.viewContext
        let page: ManagedRepoPage? = managedContext.fetch()
        
        managedContext.perform {
            if let oldPage = page {
                let existingRepos: [ManagedRepo] = managedContext.fetchGroup(key: #keyPath(ManagedRepo.id), value: newRepos.map { $0.id })
                let newRepos = newRepos
                    .map { repo -> ManagedRepo in
                        if let existingRepoIndex = existingRepos.firstIndex(where: { Int($0.id) == repo.id }) {
                            let existingRepo = existingRepos[existingRepoIndex]
                            existingRepo.update(with: repo)
                            return existingRepo
                        } else {
                            return ManagedRepo(plain: repo, context: managedContext)
                        }
                }
                
                oldPage.repos = NSOrderedSet(array: newRepos)
            } else {
                let newPage = RepoPage()
                newPage.repos = newRepos
                
                managedContext.insert(ManagedRepoPage(plain: newPage, context: managedContext))
            }
            
            managedContext.saveContextChanges()
        }
    }
    
    
    // MARK: - Private methods
    
    @objc private func managedObjectContextObjectsDidChange() {
        contextWasChanged?()
    }
}
