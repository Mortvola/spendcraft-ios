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
        HStack() {
            Text(formatDate(date: trx.date))
            HStack {
                Text(trx.name)
                Spacer()
            }
            AmountView(amount: trx.amount)
        }
    }
}

struct AccountTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        AccountTransactionView(trx: .constant(Transaction.sampleData[0]))
    }
}
