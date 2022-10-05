//
//  AccountTransactionView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/30/22.
//

import SwiftUI

struct AccountTransactionView: View {
    @Binding var trx: Transaction
    @Binding var categories: Categories
    @State var data = Transaction.Data()
    @State var isEditingTrx = false

    func saveTransaction() {
        trx.save() { result in
            switch result {
            case .failure(let error):
                fatalError(error.localizedDescription)
            case .success(let updateTrxResponse):
//                let transaction = Transaction(trx: updateTrxResponse.transaction)
                
                // If the transaction has no categories assigned and the
                // current category is not the unassigned category
                // OR if the transation has categories and non of them
                // match the current category then remove the transaction
                // from the transactions array
//                if ((transaction.categories.count == 0 && category.type != .unassigned) || (transaction.categories.count != 0 && !transaction.hasCategory(categoryId: category.id))) {
//
//                    // Find the index of the transaction in the transactions array
//                    let index = transactions.firstIndex(where: {
//                        $0.id == trx.id
//                    })
//
//                    // If the index was found then remove the transation from
//                    // the transactions array
//                    if let index = index {
//                        transactions.remove(at: index)
//
//                        // If this is the unassigned category then
//                        // set the badge to the new number of transactions
//                        if (category.type == .unassigned) {
//                            UIApplication.shared.applicationIconBadgeNumber = transactions.count
//                        }
//                    }
//                }
                
                updateTrxResponse.categories.forEach { cat in
                    categories.updateBalance(categoryId: cat.id, balance: cat.balance)
                }
            }
        }
    }

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
                            trx.update(from: data)
                            saveTransaction()
                        }
                        .disabled(!data.isValid)
                    }
                }
            }
        }
    }
}

struct AccountTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        AccountTransactionView(trx: .constant(SampleData.transactions[0]), categories: .constant(SampleData.categories))
    }
}
