//
//  AccountTransactionView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/30/22.
//

import SwiftUI

struct AccountTransactionView: View {
    @Binding var trx: Transaction

    var body: some View {
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
}

struct AccountTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        AccountTransactionView(trx: .constant(SampleData.transactions[0]))
    }
}
