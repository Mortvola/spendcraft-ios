//
//  AccountsStore.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/29/22.
//

import Foundation
import Framework
import Http

class AccountsStore: ObservableObject {
    @Published var accounts: [Institution] = []
    @Published var loading = false

    private var loaded = false
    
    private var accountDictionary: Dictionary<Int, Account> = Dictionary()
    
    static let shared: AccountsStore = AccountsStore()
    
    @MainActor
    func load(force: Bool = false) async {
        if !self.loaded || force {
            self.loading = true
            
            if let accountsResponse: Http.Response<[Response.Institution]> = try? await Http.get(path: "/api/v1/connected-accounts") {
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
            self.loading = false
        }
    }
    
    func getAccount(accountId: Int) -> Account? {
        accountDictionary[accountId]
    }
}
