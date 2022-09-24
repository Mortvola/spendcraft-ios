//
//  SampleData.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/23/22.
//

import Foundation

extension Transaction {
    static let sampleData: [Transaction] = [
        Transaction(id: 0, date: "2022-09-10", name: "Costco", amount: 170.24, institution: "Citi", account: "Credit Card", comment: nil, transactionCategories: [
            Transaction.Category(id: 0, categoryId: 0, amount: 145.2, comment: "This is a comment"),
            Transaction.Category(id: 1, categoryId: 2, amount: 512.23, comment: "This is another comment")
        ]),
        Transaction(id: 0, date: "2022-09-18", name: "Safeway", amount: 170.24, institution: "Citi", account: "Credit Card", comment: nil, transactionCategories: [
            Transaction.Category(id: 0, categoryId: 0, amount: 325.2, comment: "This is a comment"),
            Transaction.Category(id: 1, categoryId: 2, amount: 999999.99, comment: "This is another comment")
        ])
    ]

}
