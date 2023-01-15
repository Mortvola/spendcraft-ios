//
//  AccountsStore.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/29/22.
//

import Foundation
import Framework
import Http

class Account: ObservableObject, Identifiable, Hashable {
    var id: Int
    @Published var name: String
    @Published var balance: Double
    var closed: Bool
    @Published var syncDate: Date?
    var institution: Institution?

    @Published var transactionState = TransactionState.Posted

    init(id: Int, name: String, balance: Double, closed: Bool) {
        self.id = id
        self.name = name
        self.balance = balance
        self.closed = closed
    }

    init(account: Response.Account, institution: Institution) {
        self.id = account.id
        self.name = account.name
        self.balance = account.balance
        self.closed = account.closed
        self.syncDate = account.syncDate
        self.institution = institution
    }

    static func == (lhs: Account, rhs: Account) -> Bool {
        lhs === rhs
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
}

class Institution: ObservableObject, Identifiable {
    var id: Int
    @Published var name: String
    var accounts: [Account]
    
    init(id: Int, name: String, accounts: [Account]) {
        self.id = id
        self.name = name
        self.accounts = accounts
    }

    init(institution: Response.Institution) {
        self.id = institution.id
        self.name = institution.name
        self.accounts = []

        self.accounts = institution.accounts.map { account in
            Account(account: account, institution: self)
        }

        self.accounts.sort {
            $0.name < $1.name
        }
    }
}

class AccountsStore: ObservableObject {
    @Published var accounts: [Institution] = []
    
    var loaded = false
    
    private var accountDictionary: Dictionary<Int, Account> = Dictionary()

    static let shared: AccountsStore = AccountsStore()
    
    @MainActor
    func load() async {
        if let accountsResponse: Http.Response<[Response.Institution]> = try? await Http.get(path: "/api/connected-accounts") {
            if let accountsResponse = accountsResponse.data {
                var accounts: [Institution] = accountsResponse.map {
                    Institution(institution: $0)
                };
                
                accounts.sort {
                    $0.name < $1.name
                }
                
                self.accounts = accounts
                
                // Build a dictionary of the accounts for faster lookup
                self.accountDictionary = Dictionary()
                
                self.accounts.forEach { institution in
                    institution.accounts.forEach { account in
                        self.accountDictionary.updateValue(account, forKey: account.id)
                    }
                }
            }
        }
        
        self.loaded = true
    }
    
    func getAccount(accountId: Int) -> Account? {
        accountDictionary[accountId]
    }
}
