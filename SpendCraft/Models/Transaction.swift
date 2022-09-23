//
//  Transaction.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/16/22.
//

import Foundation

struct Transaction: Identifiable, Codable {
    struct Category: Identifiable, Codable {
        var id: Int?
        var categoryId: Int?
        var amount: Double
        var comment: String
        
        init() {
            self.amount = 0
            self.comment = ""
        }

        init(id: Int, categoryId: Int, amount: Double, comment: String?) {
            self.id = id
            self.categoryId = categoryId
            self.amount = amount
            self.comment = comment ?? ""
        }
        
        init(trxCategory: TransactionsResponse.Transaction.TransactionCategory) {
            self.id = trxCategory.id
            self.categoryId = trxCategory.categoryId
            self.amount = trxCategory.amount
            self.comment = trxCategory.comment ?? ""
        }
    }
    
    var id: Int
    var date: Date?
    var name: String
    var amount: Double
    var institution: String
    var account: String
    var categories: [Category] = []
    
    init(id: Int, date: String, name: String, amount: Double, institution: String, account: String, transactionCategories: [Category]) {
        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "y-M-d"
        
        self.id = id
        self.date = dateFormatter.date(from: date)
        self.name = name
        self.amount = amount
        self.institution = institution
        self.account = account
        self.categories = transactionCategories
    }
    
    init(trx: TransactionsResponse.Transaction) {
        self.id = trx.id
        self.date = trx.date
        self.name = trx.accountTransaction?.name ?? ""
        self.amount = trx.accountTransaction?.amount ?? 0
        self.institution = trx.accountTransaction?.account.institution.name ?? ""
        self.account = trx.accountTransaction?.account.name ?? ""
        self.categories = trx.transactionCategories.map {
            Category(trxCategory: $0)
        }
    }
}

extension Transaction {
    struct Data {
        var date: Date?
        var name: String = ""
        var amount: Double = 0.0
        var institution: String = ""
        var account: String = ""
        var categories: [Category] = []
    }
    
    var data: Data {
        Data(date: date, name: name, amount: amount, institution: institution, account: account, categories: categories)
    }
}

func formatDate(date: Date?) -> String {
    guard let date = date else {
        return ""
    }

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd/yy"
    return dateFormatter.string(from: date)
}
