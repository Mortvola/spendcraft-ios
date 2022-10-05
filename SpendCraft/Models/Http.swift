//
//  Http.swift
//  SpendCraft
//
//  Created by Richard Shields on 10/4/22.
//

import Foundation

let serverName = "spendcraft.app"

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

func getUrl(path: String) -> URL? {
    return URL(string: "https://\(serverName)\(path)")
}

struct Http {
    // POST requests
    static func post(path: String, data: Encodable, _ completion: @escaping (Data?) -> Void) throws -> Void {
        try Http.sendRequest(method: "POST", path: path, data: data, completion)
    }

    static func post(path: String, data: Encodable) throws -> Void {
        try Http.sendRequest(method: "POST", path: path, data: data)
    }

    static func post(path: String, _ completion: @escaping (Data?) -> Void) throws -> Void {
        try Http.sendRequest(method: "POST", path: path, completion)
    }
    
    // GET requests
    static func get(path: String, _ completion: @escaping (Data?) -> Void) throws -> Void {
        try Http.sendRequest(method: "GET", path: path, completion)
    }

    // PATCH requests
    static func patch(path: String, data: Encodable, _ completion: @escaping (Data?) -> Void) throws -> Void {
        try Http.sendRequest(method: "PATCH", path: path, data: data, completion)
    }

    private static func sendRequest(method: String, path: String, _ completion: @escaping (Data?) -> Void) throws -> Void {
        guard let url = getUrl(path: path) else {
            throw MyError.runtimeError("failed to get URL")
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = try getSession()

        let task = session.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                print("Error: \(error)");
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                print ("response is nil")
                return
            }
            
            guard (200...299).contains(response.statusCode) else {
                print ("Server error: \(response.statusCode)")
                return
            }
            
            print("success: \(response.statusCode)")
            
            completion(data)
        }
        
        task.resume()
    }

    private static func sendRequest(method: String, path: String, data: Encodable, _ completion: @escaping (Data?) -> Void) throws -> Void {
        guard let url = getUrl(path: path) else {
            throw MyError.runtimeError("failed to get URL")
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        guard let uploadData = try? JSONEncoder().encode(data) else {
            return
        }
        
        let session = try getSession()

        let task = session.uploadTask(with: urlRequest, from: uploadData) { data, response, error in
            if let error = error {
                print("Error: \(error)");
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                print ("response is nil")
                return
            }
            
            guard (200...299).contains(response.statusCode) else {
                print ("Server error: \(response.statusCode)")
                return
            }
            
            print("success: \(response.statusCode)")
            
            completion(data)
        }
        
        task.resume()
    }

    private static func sendRequest(method: String, path: String, data: Encodable) throws -> Void {
        guard let url = getUrl(path: path) else {
            throw MyError.runtimeError("failed to get URL")
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        guard let uploadData = try? JSONEncoder().encode(data) else {
            return
        }
        
        let session = try getSession()

        let task = session.uploadTask(with: urlRequest, from: uploadData) { data, response, error in
            if let error = error {
                print("Error: \(error)");
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                print ("response is nil")
                return
            }
            
            guard (200...299).contains(response.statusCode) else {
                print ("Server error: \(response.statusCode)")
                return
            }
            
            print("success: \(response.statusCode)")
        }
        
        task.resume()
    }
}
