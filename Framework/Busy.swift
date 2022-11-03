//
//  Busy.swift
//  Framework
//
//  Created by Richard Shields on 11/2/22.
//

import Foundation

public class Busy: ObservableObject {
    @Published public var busy = false
    
    public static var shared = Busy()
    
    public func start() {
        busy = true
    }
    
    public func stop() {
        busy = false
    }
}
