//
//  TransactionDetailView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/18/22.
//

import SwiftUI

struct TransactionDetailView: View {
    @Binding var transaction: Transaction

    func formatDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        return dateFormatter.string(from: transaction.date)
    }

    var body: some View {
        List {
            HStack {
                Text("Date")
                Spacer()
                Text(formatDate(date: transaction.date))
            }
            HStack {
                Text("Name")
                Spacer()
                Text(transaction.name)
            }
            HStack {
                Text("Amount")
                Spacer()
                Text(String(format: "%.2f", transaction.amount))
            }
            HStack {
                Text("Institution")
                Spacer()
                Text(transaction.institution)
            }
            HStack {
                Text("Account")
                Spacer()
                Text(transaction.account)
            }
            Section(header: Text("Categories")) {
                
            }
        }
        .padding(.horizontal)
    }
}

struct TransactionDetailView_Previews: PreviewProvider {
    static let transaction = try! Transaction(id: 0, date: "2022-11-15", name: "Costco", amount: 300.0, institution: "Citi", account: "Checking")

    static var previews: some View {
        TransactionDetailView(transaction: .constant(transaction))
    }
}
