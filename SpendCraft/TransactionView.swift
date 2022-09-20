//
//  TransactionView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/16/22.
//

import SwiftUI

struct TransactionView: View {
    var transaction: Transaction

    func formatDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        return dateFormatter.string(from: transaction.date)
    }

    func formatAccount(institution: String?, account: String?) -> String {
        guard let institution = institution, let account = account else {
            return ""
        }
        
        if (institution != "" && account != "") {
            return "\(institution): \(account)"
        }
        
        return ""
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack() {
                Text(formatDate(date: transaction.date))
                HStack {
                    Text(transaction.name)
                    Spacer()
                }
                AmountView(amount: transaction.amount)
            }
            
            HStack {
                Text(formatAccount(institution: transaction.institution, account:  transaction.account))
                    .font(.caption)
            }
        }
    }
}

struct TransactionView_Previews: PreviewProvider {
    static let transaction = try! Transaction(id: 0, date: "2022-11-15", name: "Costco", amount: 300.0, institution: "Citi", account: "Checking")

    static var previews: some View {
        TransactionView(transaction: transaction)
    }
}
