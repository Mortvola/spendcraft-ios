//
//  Account.swift
//  SpendCraft
//
//  Created by Richard Shields on 1/27/23.
//

import Foundation
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
    
    func uploadOfx(file: URL) async {
        try? await Http.uploadFile(path: "/api/v1/account/\(self.id)/ofx", file: file, mimeType: "text/plain")
    }
}

