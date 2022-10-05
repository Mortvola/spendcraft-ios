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
        
        self.accounts.sort {
            $0.name < $1.name
        }
    }
}

class AccountsStore: ObservableObject {
    @Published var accounts: [Institution] = []

    static func load(completion: @escaping (Result<[Institution], Error>)->Void) {
        try? Http.get(path: "/api/connected-accounts") { data in
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

            var accounts: [Institution] = accountsResponse.map{
                Institution(institution: $0)
            };
            
            accounts.sort {
                $0.name < $1.name
            }
        
            DispatchQueue.main.async {
                completion(.success(accounts))
            }
        }
    }
}
