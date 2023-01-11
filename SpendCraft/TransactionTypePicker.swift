//
//  TransactionTypePicker.swift
//  SpendCraft
//
//  Created by Richard Shields on 10/11/22.
//

import SwiftUI

struct TransactionTypePicker: View {
    @Binding var transactionState: TransactionState

    var body: some View {
        HStack {
            Spacer()
            Picker(selection: $transactionState, label: Text("Type")) {
                Text("Posted Transactions").tag(TransactionState.Posted)
                Text("Pending Transations").tag(TransactionState.Pending)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            Spacer()
        }
    }
}

struct TransactionTypePicker_Previews: PreviewProvider {
    static let transactionState = TransactionState.Posted
    
    static var previews: some View {
        TransactionTypePicker(transactionState: .constant(transactionState))
    }
}
