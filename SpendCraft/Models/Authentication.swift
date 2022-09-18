//
//  Authentication.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/18/22.
//

import Foundation

class Authentication: ObservableObject {
    @Published var authenticated = false

    static func signIn(username: String, password: String, completion: @escaping (Result<Bool, Error>)->Void) {
        if let url = URL(string: "https://spendcraft.app/login") {
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            guard let session = try? getSession() else {
                return
            }
            
            struct Data: Codable {
                var username: String
                var password: String
            }
            
            let data = Data(username: username, password: password)
            
            guard let uploadData = try? JSONEncoder().encode(data) else {
                return
            }
            
            let task = session.uploadTask(with: urlRequest, from: uploadData) {data, response, error in
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
                DispatchQueue.main.async {
                    completion(.success(true))
                }
            }
            task.resume()
        }
    }
}
