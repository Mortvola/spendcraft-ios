//
//  Transaction.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/16/22.
//

import Foundation

struct Transaction: Identifiable {
    var id: UUID
    var date: Date
    var name: String
    var amount: Double
    var institution: String
    var account: String
    
    init(id: UUID = UUID(), date: String, name: String, amount: Double, institution: String, account: String) throws {
        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "y-M-d"
        
        self.id = id
        if let date = dateFormatter.date(from: date) {
            self.date = date
        }
        else {
            throw MyError.runtimeError("date is null")
        }
        self.name = name
        self.amount = amount
        self.institution = institution
        self.account = account
    }
}
