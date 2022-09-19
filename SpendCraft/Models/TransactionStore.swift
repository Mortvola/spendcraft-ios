//
//  Store.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/18/22.
//

import Foundation

class TransactionStore: ObservableObject {
    @Published var transactions: [Transaction] = []

    static func load(completion: @escaping (Result<[Transaction], Error>)->Void) {
        guard let url = URL(string: "https://spendcraft.app/api/category/-2/transactions?offset=0&limit=30") else {
            return
        }

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
                let decoder = JSONDecoder()
                transactionsResponse = try decoder.decode(TransactionsResponse.self, from: data)
            }
            catch {
                print ("Error: \(error)")
                return
            }

            let transactions: [Transaction] = transactionsResponse.transactions.map {
                Transaction(trx: $0)
            }
        
            DispatchQueue.main.async {
                completion(.success(transactions))
            }
        }
        task.resume()
    }
}
