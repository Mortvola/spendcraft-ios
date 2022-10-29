//
//  Http.swift
//  SpendCraft
//
//  Created by Richard Shields on 10/4/22.
//

import Foundation

public struct Http {
    public static let serverName = "spendcraft.app"

    private static var session: URLSession?

    // POST requests
    public static func post(path: String, data: Encodable, _ completion: @escaping (Data?) -> Void) throws {
        try Http.sendRequest(method: "POST", path: path, data: data, completion)
    }

    public static func post(path: String, data: Encodable) throws {
        try Http.sendRequest(method: "POST", path: path, data: data)
    }

    public static func post(path: String, _ completion: @escaping (Data?) -> Void) throws {
        try Http.sendRequest(method: "POST", path: path, completion)
    }

    // PUT requests
    public static func put(path: String, data: Encodable, _ completion: @escaping (Data?) -> Void) throws {
        try Http.sendRequest(method: "PUT", path: path, data: data, completion)
    }

    public static func put(path: String, data: Encodable) async throws -> Data? {
        await withCheckedContinuation { continuation in
            try? Http.sendRequest(method: "PUT", path: path, data: data) { data in
                continuation.resume(returning: data)
            }
        }
    }

    // GET requests
    public static func get<T: Decodable>(path: String) async throws -> T {
        let data = await withCheckedContinuation { continuation in
            try? Http.sendRequest(method: "GET", path: path) { data in
                continuation.resume(returning: data)
            }
        }

        guard let data = data else {
            throw MyError.runtimeError("Data is nil")
        }

        return try JSONDecoder().decode(T.self, from: data)
    }

    // PATCH requests
    public static func patch(path: String, data: Encodable, _ completion: @escaping (Data?) -> Void) throws {
        try Http.sendRequest(method: "PATCH", path: path, data: data, completion)
    }
    
    // DELETE requests
    public static func delete(path: String, _ completion: @escaping (Data?) -> Void) throws {
        try Http.sendRequest(method: "DELETE", path: path, completion)
    }
    
    private static func checkResponse(error: Error?, response: URLResponse?) -> Bool {
        if let error = error {
            print("Error: \(error)");
            return false
        }
        
        guard let response = response as? HTTPURLResponse else {
            print ("response is nil")
            return false
        }
        
        guard (200...299).contains(response.statusCode) else {
            print ("Server error: \(response.statusCode)")
            return false
        }
        
        return true
    }
    
    private static func dataTask(urlRequest: URLRequest, _ completion: @escaping (Data?) -> Void) throws {
        let session = try getSession()
        
        let task = session.dataTask(with: urlRequest) { data, response, error in
            if !checkResponse(error: error, response: response) {
                return
            }
            
            completion(data)
        }
        
        task.resume()
    }
    
    private static func uploadTask(urlRequest: URLRequest, uploadData: Data?, _ completion: @escaping (Data?) -> Void) throws {
        let session = try getSession()
        
        let task = session.uploadTask(with: urlRequest, from: uploadData) { data, response, error in
            if !checkResponse(error: error, response: response) {
                return
            }
            
            completion(data)
        }
        
        task.resume()
    }

    private static func uploadTask(urlRequest: URLRequest, uploadData: Data?) throws {
        let session = try getSession()
        
        let task = session.uploadTask(with: urlRequest, from: uploadData) { _, response, error in
            if !checkResponse(error: error, response: response) {
                return
            }
        }
        
        task.resume()
    }

    private static func sendRequest(method: String, path: String, _ completion: @escaping (Data?) -> Void) throws {
        guard let url = getUrl(path: path) else {
            throw MyError.runtimeError("failed to get URL")
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        try dataTask(urlRequest: urlRequest, completion)
    }
    
    private static func sendRequest(method: String, path: String, data: Encodable, _ completion: @escaping (Data?) -> Void) throws {
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
        
        try uploadTask(urlRequest: urlRequest, uploadData: uploadData, completion)
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
        
        try uploadTask(urlRequest: urlRequest, uploadData: uploadData)
    }
    
    private static func getSession() throws -> URLSession {
        if (session == nil) {
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = 60

            session = URLSession(configuration: configuration)
            session?.sessionDescription = "spendcraft shared"
        }
        
        guard let session = session else {
            throw MyError.runtimeError("session is nil")
        }

        return session;
    }

    private static func getUrl(path: String) -> URL? {
        return URL(string: "https://\(serverName)\(path)")
    }
}
