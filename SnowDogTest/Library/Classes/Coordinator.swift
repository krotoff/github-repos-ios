//
//  Coordinator.swift
//  SnowDogTest
//
//  Created by Andrew Krotov on 03.02.2020.
//  Copyright © 2020 Andrew Krotov. All rights reserved.
//

import Foundation

public class Coordinator: NSObject {
    
    // MARK: - Public properties
        
    public var onCompleted: (() -> ())!
    
    // MARK: - Private properties
    
    private var childCoordinators = [UUID: Coordinator]()
    private let identifier = UUID()
    
    // MARK: - Public methods
    
    public func store(_ coordinator: Coordinator) {
        childCoordinators[coordinator.identifier] = coordinator
        coordinator.start()
    }
    
    public func free(_ coordinator: Coordinator) {
        childCoordinators.removeValue(forKey: coordinator.identifier)
    }
    
    public func start() {
        fatalError()
    }
}
