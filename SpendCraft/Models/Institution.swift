//
//  Institution.swift
//  SpendCraft
//
//  Created by Richard Shields on 1/27/23.
//

import Foundation

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

