//
//  TransactionTypePicker.swift
//  SpendCraft
//
//  Created by Richard Shields on 10/11/22.
//

import SwiftUI

struct TransactionTypePicker: View {
    @Binding var transactionType: Int

    var body: some View {
        HStack {
            Spacer()
            Picker(selection: $transactionType, label: Text("Type")) {
                Text("Posted Transactions").tag(0)
                Text("Pending Transations").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            Spacer()
        }
    }
}

struct TransactionTypePicker_Previews: PreviewProvider {
    static let transactionType = 0
    
    static var previews: some View {
        TransactionTypePicker(transactionType: .constant(transactionType))
    }
}
