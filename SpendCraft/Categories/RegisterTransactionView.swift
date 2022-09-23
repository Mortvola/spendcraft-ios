//
//  RegisterTransactionView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/21/22.
//

import SwiftUI

struct RegisterTransactionView: View {
    @Binding var trx: Transaction
    @State var data = Transaction.Data()
    @State var isEditingTrx = false
    let categories: Categories
    
    var body: some View {
        Button(action: {
            isEditingTrx = true
            data = trx.data
        }) {
            TransactionView(transaction: trx)
        }
        .sheet(isPresented: $isEditingTrx) {
            NavigationView {
                TransactionEdit(transaction: $data, categories: categories)
                .navigationTitle("Editing Transaction")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            isEditingTrx = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            isEditingTrx = false;
                            // scrum.update(from: data)
                        }
                    }
                }
            }
        }
    }
}

struct RegisterTransactionView_Previews: PreviewProvider {
    static let categories = Categories(tree: [])

    static var previews: some View {
        RegisterTransactionView(trx: .constant(Transaction.sampleData[0]), categories: categories)
    }
}
