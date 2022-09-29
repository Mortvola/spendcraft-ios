//
//  AccountsStore.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/29/22.
//

import Foundation

struct Account: Identifiable {
    var id: Int
    var name: String
    var balance: Double
    var closed: Bool
    var syncDate: Date?

    init(id: Int, name: String, balance: Double, closed: Bool) {
        self.id = id
        self.name = name
        self.balance = balance
        self.closed = closed
    }

    init(account: AccountResponse) {
        self.id = account.id
        self.name = account.name
        self.balance = account.balance
        self.closed = account.closed
        self.syncDate = account.syncDate
    }
}

struct Institution: Identifiable {
    var id: Int
    var name: String
    var accounts: [Account]
    
    init(id: Int, name: String, accounts: [Account]) {
        self.id = id
        self.name = name
        self.accounts = accounts
    }

    init(institution: InstitutionResponse) {
        self.id = institution.id
        self.name = institution.name
        self.accounts = institution.accounts.map { account in
            Account(account: account)
        }
    }
}

class AccountsStore: ObservableObject {
    @Published var accounts: [Institution] = []

    static func load(completion: @escaping (Result<[Institution], Error>)->Void) {
        guard let url = URL(string: "https://spendcraft.app/api/connected-accounts") else {
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
            
            var accountsResponse: [InstitutionResponse]
            do {
                accountsResponse = try JSONDecoder().decode([InstitutionResponse].self, from: data)
            }
            catch {
                print ("Error: \(error)")
                return
            }

            let accounts: [Institution] = accountsResponse.map{
                Institution(institution: $0)
            };
        
            DispatchQueue.main.async {
                completion(.success(accounts))
            }
        }
        task.resume()
    }
}
