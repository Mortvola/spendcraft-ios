//
//  SampleData.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/23/22.
//

import Foundation
import Framework

struct SampleData {
    static let transactions: [Transaction] = [
        Transaction(id: 0, date: "2022-09-10", name: "Costco with a really, really, really long name", amount: -170.24, institution: "Citi", account: "Credit Card", comment: nil, transactionCategories: [
            Transaction.Category(id: 0, categoryId: 0, amount: -145.2, comment: "This is a comment"),
            Transaction.Category(id: 1, categoryId: 2, amount: -25.04, comment: "This is another comment")
        ], type: .regular),
        Transaction(id: 0, date: "2022-09-18", name: "Safeway", amount: 170.24, institution: "Citi", account: "Credit Card", comment: nil, transactionCategories: [
            Transaction.Category(id: 0, categoryId: 0, amount: 325.2, comment: "This is a comment"),
            Transaction.Category(id: 1, categoryId: 2, amount: 999999.99, comment: "This is another comment")
        ], type: .regular)
    ]

    static let categoryDictionary = [
        0: SpendCraft.Category(id: 0, groupId: 0, name: "Test Category", balance: 100.0, type: .regular, monthlyExpenses: false)
    ]
    
    static let categories = CategoriesStore()
}
