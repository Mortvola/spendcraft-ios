//
//  Store.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/18/22.
//

import Foundation

class TransactionStore: ObservableObject {
    @Published var transactions: [Transaction] = []

    static private func load(url: URL, completion: @escaping (Result<TransactionsResponse, Error>)->Void) {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        guard let session = try? getSession() else {
            return
        }

        let task = session.dataTask(with: urlRequest) {data, response, error in
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
            
            guard let data = data else {
                print ("data is nil")
                return;
            }
            
            var transactionsResponse: TransactionsResponse
            do {
                transactionsResponse = try JSONDecoder().decode(TransactionsResponse.self, from: data)
            }
            catch {
                print ("Error: \(error)")
                return
            }

            DispatchQueue.main.async {
                completion(.success(transactionsResponse))
            }
        }
        
        task.resume()
    }

    static func load(account: Account, completion: @escaping (Result<TransactionsResponse, Error>)->Void) {
        guard let url = URL(string: "https://spendcraft.app/api/account/\(account.id)/transactions?offset=0&limit=30") else {
            return
        }

        load(url: url, completion: completion)
    }

    static func load(category: Categories.Category, completion: @escaping (Result<TransactionsResponse, Error>)->Void) {
        guard let url = URL(string: "https://spendcraft.app/api/category/\(category.id)/transactions?offset=0&limit=30") else {
            return
        }

        load(url: url, completion: completion)
    }
    
    static func sync(institution: Institution, account: Account, completion: @escaping (Result<Bool, Error>)->Void) {
        guard let url = URL(string: "https://spendcraft.app/api/institution/\(institution.id)/accounts/\(account.id)/transactions/sync") else {
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        guard let session = try? getSession() else {
            return
        }

        let task = session.dataTask(with: urlRequest) {data, response, error in
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
            
//            guard let data = data else {
//                print ("data is nil")
//                return;
//            }
//
//            var transactionsResponse: TransactionsResponse
//            do {
//                transactionsResponse = try JSONDecoder().decode(TransactionsResponse.self, from: data)
//            }
//            catch {
//                print ("Error: \(error)")
//                return
//            }

            DispatchQueue.main.async {
                completion(.success(true))
            }
        }
        
        task.resume()
    }
}
