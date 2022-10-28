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
    var postedTransaction: Bool

    var body: some View {
        Button(action: {
            trx.data () { d in
                isEditingTrx = true
                data = d
            }
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
                    if let runningBalance = trx.runningBalance {
                        SpendCraft.AmountView(amount: runningBalance)
                    }
                }
                .font(.caption)
                .lineLimit(1)
            }
        }
        .sheet(isPresented: $isEditingTrx) {
            TransactionEdit(transaction: trx, isEditingTrx: $isEditingTrx, trxData: $data, transactionStore: transactionStore, category: nil, postedTransaction: postedTransaction)
        }
    }
}

struct AccountTransactionView_Previews: PreviewProvider {
    static let transactionStore = TransactionStore()
    
    static var previews: some View {
        AccountTransactionView(trx: SampleData.transactions[0], transactionStore: transactionStore, postedTransaction: true)
    }
}
