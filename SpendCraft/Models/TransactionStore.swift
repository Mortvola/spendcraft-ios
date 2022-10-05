//
//  Store.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/18/22.
//

import Foundation

class TransactionStore: ObservableObject {
    @Published var transactions: [Transaction] = []

    static private func load(path: String, completion: @escaping (Result<TransactionsResponse, Error>)->Void) {
        try? Http.get(path: path) { data in
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
    }

    static func load(account: Account, completion: @escaping (Result<TransactionsResponse, Error>)->Void) {
        load(path: "/api/account/\(account.id)/transactions?offset=0&limit=30", completion: completion)
    }

    static func load(category: Categories.Category, completion: @escaping (Result<TransactionsResponse, Error>)->Void) {
        load(path: "/api/category/\(category.id)/transactions?offset=0&limit=30", completion: completion)
    }
    
    static func sync(institution: Institution, account: Account, completion: @escaping (Result<Bool, Error>)->Void) {
        try? Http.post(path: "/api/institution/\(institution.id)/accounts/\(account.id)/transactions/sync") { _ in
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
    }
}
