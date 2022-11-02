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
    public static func post<T: Decodable>(path: String, data: Encodable) async throws -> T {
        let data = try await Http.sendRequest(method: "POST", path: path, data: data)

        guard let data = data else {
            throw MyError.runtimeError("Data is nil")
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        }
        catch {
            print("\(error.localizedDescription)")
            throw error
        }
    }

    public static func post(path: String, data: Encodable) async throws {
        try await Http.sendRequest(method: "POST", path: path, data: data)
    }

    public static func post<T: Decodable>(path: String) async throws -> T {
        let data = try await Http.sendRequest(method: "POST", path: path)

        guard let data = data else {
            throw MyError.runtimeError("Data is nil")
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        }
        catch {
            print("\(error.localizedDescription)")
            throw error
        }
    }

    // PUT requests
    public static func put(path: String, data: Encodable) async throws {
        try await Http.sendRequest(method: "PUT", path: path, data: data)
    }

    public static func put<T: Decodable>(path: String, data: Encodable) async throws -> T {
        let data = try await Http.sendRequest(method: "PUT", path: path, data: data)

        guard let data = data else {
            throw MyError.runtimeError("Data is nil")
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        }
        catch {
            print("\(error.localizedDescription)")
            throw error
        }
    }

    // GET requests
    public static func get<T: Decodable>(path: String) async throws -> T {
        let data = try await Http.sendRequest(method: "GET", path: path)

        guard let data = data else {
            throw MyError.runtimeError("Data is nil")
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        }
        catch {
            print("\(error.localizedDescription)")
            throw error
        }
    }

    // PATCH requests
    public static func patch<T: Decodable>(path: String, data: Encodable) async throws -> T {
        let data = try await Http.sendRequest(method: "PATCH", path: path, data: data)

        guard let data = data else {
            throw MyError.runtimeError("Data is nil")
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        }
        catch {
            print("\(error.localizedDescription)")
            throw error
        }
    }
    
    // DELETE requests
    public static func delete(path: String) async throws {
        try await Http.sendRequest(method: "DELETE", path: path)
    }
    
    private static func checkResponse(error: Error?, data: Data?, response: URLResponse?) -> Bool {
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
            if let data = data {
                let text = String(decoding: data, as: UTF8.self)
                print(text)
            }
            return false
        }
        
        return true
    }
    
    private static func dataTask(urlRequest: URLRequest) async throws -> Data? {
        let session = try getSession()
        
        return await withCheckedContinuation { continuation in
            let task = session.dataTask(with: urlRequest) { data, response, error in
                if !checkResponse(error: error, data: data, response: response) {
                    continuation.resume(returning: nil)
                    return
                }
                
                continuation.resume(returning: data)
            }
            
            task.resume()
        }
    }
    
    private static func uploadTask(urlRequest: URLRequest, uploadData: Data?) async throws -> Data? {
        let session = try getSession()
        
        return await withCheckedContinuation { continuation in
            let task = session.uploadTask(with: urlRequest, from: uploadData) { data, response, error in
                if !checkResponse(error: error, data: data, response: response) {
                    continuation.resume(returning: nil)
                    return
                }
                
                continuation.resume(returning: data)
            }
            
            task.resume()
        }
    }

    @discardableResult
    private static func sendRequest(method: String, path: String) async throws -> Data? {
        guard let url = getUrl(path: path) else {
            throw MyError.runtimeError("failed to get URL")
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        return try await dataTask(urlRequest: urlRequest)
    }
    
    @discardableResult
    private static func sendRequest(method: String, path: String, data: Encodable) async throws -> Data? {
        guard let url = getUrl(path: path) else {
            throw MyError.runtimeError("failed to get URL")
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let uploadData = try JSONEncoder().encode(data)
        
        return try await uploadTask(urlRequest: urlRequest, uploadData: uploadData)
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
