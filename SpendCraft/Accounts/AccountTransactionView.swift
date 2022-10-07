//
//  AccountTransactionView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/30/22.
//

import SwiftUI

struct AccountTransactionView: View {
    @Binding var trx: Transaction
    @Binding var transactions: [Transaction]
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
                    AmountView(amount: trx.amount)
                }
                HStack {
                    Text(formatDate(date: trx.date))
                    Text(trx.accountOwner)
                    Spacer()
                    AmountView(amount: trx.runningBalance ?? 0)
                }
                .font(.caption)
                .lineLimit(1)
            }
        }
        .sheet(isPresented: $isEditingTrx) {
            NavigationView {
                TransactionEdit(transaction: $trx, isEditingTrx: $isEditingTrx, trxData: $data, transactions: $transactions, category: nil)
            }
        }
    }
}

struct AccountTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        AccountTransactionView(trx: .constant(SampleData.transactions[0]), transactions: .constant(SampleData.transactions))
    }
}
