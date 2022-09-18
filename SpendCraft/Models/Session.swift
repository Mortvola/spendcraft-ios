//
//  Session.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/18/22.
//

import Foundation

var session: URLSession?

func getSession() throws -> URLSession {
    if (session == nil) {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60

        session = URLSession(configuration: configuration)
    }
    
    guard let session = session else {
        throw MyError.runtimeError("session is nil")
    }

    return session;
}
