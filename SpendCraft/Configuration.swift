//
//  Configuration.swift
//  SpendCraft
//
//  Created by Richard Shields on 1/17/23.
//

import Foundation

enum Configuration: String {
    case debug
    case release
    case production
    
    static let current: Configuration = {
        guard let rawValue = Bundle.main.infoDictionary?["Configuration"] as? String else {
            fatalError("No configuration found")
        }
        
        guard let configuration = Configuration(rawValue: rawValue.lowercased()) else {
            fatalError("Invalid configuration")
        }
        
        return configuration
    }()
    
    static var baseURL: String {
        switch(Configuration.current) {
        case .debug, .release:
            return "http://sandbox.spendcraft.app:3334"
        case .production:
            return "https://spendcraft.app"
        }
    }
}
