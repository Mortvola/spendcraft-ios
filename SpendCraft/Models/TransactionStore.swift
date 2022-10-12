//
//  Store.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/18/22.
//

import Foundation
import Framework

class TransactionStore: ObservableObject {
    @Published var transactions: [Transaction] = []

    static private func load(path: String, completion: @escaping (Result<Response.Transactions, Error>)->Void) {
        try? Http.get(path: path) { data in
            guard let data = data else {
                print ("data is nil")
                return;
            }
            
            var transactionsResponse: Response.Transactions
            do {
                transactionsResponse = try JSONDecoder().decode(Response.Transactions.self, from: data)
            }
            catch {
                print ("Error: \(error)")
                return
            }

            DispatchQueue.main.async {
                completion(.success(transactionsResponse))
            }
        }
    }

    static func loadPending(account: Account, completion: @escaping (Result<[Response.Transaction], Error>)->Void) {
        try? Http.get(path: "/api/account/\(account.id)/transactions/pending?offset=0&limit=30") { data in
            guard let data = data else {
                print ("data is nil")
                return;
            }
            
            var pendingResponse: [Response.Transaction]
            do {
                pendingResponse = try JSONDecoder().decode([Response.Transaction].self, from: data)
            }
            catch {
                print ("Error: \(error)")
                return
            }

            DispatchQueue.main.async {
                completion(.success(pendingResponse))
            }
        }
    }

    static func loadPending(category: SpendCraft.Category, completion: @escaping (Result<[Response.Transaction], Error>)->Void) {
        try? Http.get(path: "/api/category/\(category.id)/transactions/pending?offset=0&limit=30") { data in
            guard let data = data else {
                print ("data is nil")
                return;
            }
            
            var pendingResponse: [Response.Transaction]
            do {
                pendingResponse = try JSONDecoder().decode([Response.Transaction].self, from: data)
            }
            catch {
                print ("Error: \(error)")
                return
            }

            DispatchQueue.main.async {
                completion(.success(pendingResponse))
            }
        }
    }

    static func load(account: Account, completion: @escaping (Result<Response.Transactions, Error>)->Void) {
        load(path: "/api/account/\(account.id)/transactions?offset=0&limit=30", completion: completion)
    }

    static func load(category: SpendCraft.Category, completion: @escaping (Result<Response.Transactions, Error>)->Void) {
        load(path: "/api/category/\(category.id)/transactions?offset=0&limit=30", completion: completion)
    }
    
    static func sync(account: Account, completion: @escaping (Result<Response.AccountSync, Error>)->Void) {
        if let institution = account.institution {
            try? Http.post(path: "/api/institution/\(institution.id)/accounts/\(account.id)/transactions/sync") { data in
                guard let data = data else {
                    return
                }
                
                let accountSync: Response.AccountSync
                do {
                    accountSync = try JSONDecoder().decode(Response.AccountSync.self, from: data)
                }
                catch {
                    print ("Error: \(error)")
                    return
                }
        
                DispatchQueue.main.async {
                    completion(.success(accountSync))
                }
            }
        }
    }
}
