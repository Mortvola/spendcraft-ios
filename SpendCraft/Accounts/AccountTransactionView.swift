//
//  AccountTransactionView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/30/22.
//

import SwiftUI
import Framework

struct AccountTransactionView: View {
    @ObservedObject var trx: Transaction
    var transactionStore = TransactionStore.shared
    @State var isEditingTrx = false
    var postedTransaction: Bool

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
                    SpendCraft.AmountView(amount: trx.amount)
                }
                HStack {
                    Text(formatDate(date: trx.date))
                    Text(trx.accountOwner)
                    Spacer()
                    if let runningBalance = trx.runningBalance {
                        SpendCraft.AmountView(amount: runningBalance)
                    }
                }
                .font(.caption)
                .lineLimit(1)
            }
        }
        .sheet(isPresented: $isEditingTrx) {
            TransactionEdit(transaction: trx, isEditingTrx: $isEditingTrx, category: nil, postedTransaction: postedTransaction)
        }
    }
}

struct AccountTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        AccountTransactionView(trx: SampleData.transactions[0], postedTransaction: true)
    }
}
