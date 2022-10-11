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
    @ObservedObject var transactionStore: TransactionStore
    @State var data = Transaction.Data()
    @State var isEditingTrx = false

    var body: some View {
        Button(action: {
            isEditingTrx = true
            data = trx.data
        }) {
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
                    SpendCraft.AmountView(amount: trx.runningBalance ?? 0)
                }
                .font(.caption)
                .lineLimit(1)
            }
        }
        .sheet(isPresented: $isEditingTrx) {
            TransactionEdit(transaction: trx, isEditingTrx: $isEditingTrx, trxData: $data, transactionStore: transactionStore, category: nil)
        }
    }
}

struct AccountTransactionView_Previews: PreviewProvider {
    static let transactionStore = TransactionStore()
    
    static var previews: some View {
        AccountTransactionView(trx: SampleData.transactions[0], transactionStore: transactionStore)
    }
}
