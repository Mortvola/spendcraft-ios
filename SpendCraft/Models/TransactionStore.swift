//
//  Store.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/18/22.
//

import Foundation

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

    static func load(account: Account, completion: @escaping (Result<Response.Transactions, Error>)->Void) {
        load(path: "/api/account/\(account.id)/transactions?offset=0&limit=30", completion: completion)
    }

    static func load(category: CategoriesStore.Category, completion: @escaping (Result<Response.Transactions, Error>)->Void) {
        load(path: "/api/category/\(category.id)/transactions?offset=0&limit=30", completion: completion)
    }
    
    static func sync(institution: Institution, account: Account, completion: @escaping (Result<Response.AccountSync, Error>)->Void) {
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
