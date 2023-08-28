//
//  AppDependencies.swift
//  intel
//
//  Created by Ben Tincher on 10/25/21.
//

import Foundation

class App {
    static var dependencies = Dependencies.shared
    
    static var userLoggedIn: Bool { AuthManager.userLoggedIn }
}

class Dependencies {
    static var shared: Dependencies = Dependencies()
    
    init() {}
}
