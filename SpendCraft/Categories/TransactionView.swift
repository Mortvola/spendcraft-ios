//
//  TransactionView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/21/22.
//

import SwiftUI
import Framework

struct TransactionView: View {
    @ObservedObject var trx: Transaction
    @ObservedObject var transactionStore = TransactionStore.shared
    @ObservedObject var category: SpendCraft.Category
    @State var isEditingTrx = false
    var postedTransaction: Bool
    
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
        Button {
            Task {
                isEditingTrx = true
            }
        } label: {
            VStack(spacing: 10) {
                HStack() {
                    HStack {
                        Text(trx.name)
                            .lineLimit(1)
                        Spacer()
                    }
                    SpendCraft.AmountView(amount: trx.categoryAmount(category: category))
                }
                
                HStack {
                    Text(formatDate(date: trx.date))
                    Text(formatAccount(institution: trx.institution, account:  trx.account))
                        .lineLimit(1)
                    Spacer()
                    if let runningBalance = trx.runningBalance {
                        SpendCraft.AmountView(amount: runningBalance)
                    }
                }
                .font(.caption)

                if (!trx.accountOwner.isEmpty) {
                    HStack {
                        Text(trx.accountOwner)
                            .font(.caption)
                            .lineLimit(1)
                        Spacer()
                    }
                }
            }
        }
        .sheet(isPresented: $isEditingTrx) {
            TransactionEdit(transaction: trx, isEditingTrx: $isEditingTrx, category: category, postedTransaction: postedTransaction)
        }
    }
}

struct TransactionView_Previews: PreviewProvider {
    static let category = SpendCraft.Category(id: 0, groupId: 0, name: "Test", balance: 0, type: .regular, monthlyExpenses: false, hidden: false)

    static var previews: some View {
        TransactionView(trx: SampleData.transactions[0], category: category, postedTransaction: true)
    }
}
