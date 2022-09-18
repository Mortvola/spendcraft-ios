//
//  RegisterView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/16/22.
//

import SwiftUI

struct RegisterView: View {
    var transactions: [Transaction]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Unassigned")
                .font(.title)
            List {
                ForEach(transactions) { trx in
                    TransactionView(transaction: trx)
                }
            }
            .listStyle(.plain)
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static let transactions: [Transaction] = [
        try! Transaction(date: "2022-12-16", name: "Costco", amount: 300.0, institution: "Citi", account: "Checking"),
        try! Transaction(date: "2022-11-15", name: "Safeway", amount: 250.0, institution: "Citi", account: "Checking")
    ]
    static var previews: some View {
        RegisterView(transactions: transactions)
    }
}
