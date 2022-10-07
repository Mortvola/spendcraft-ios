//
//  TransactionDetailView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/18/22.
//

import SwiftUI

struct TransactionEdit: View {
    @Binding var transaction: Transaction
    @Binding var isEditingTrx: Bool
    @Binding var trxData: Transaction.Data
    @Binding var transactions: [Transaction]
    let category: Categories.Category?
    @EnvironmentObject var categoriesStore: CategoriesStore
    static var next: Int = 0

    static func nextId() -> Int {
        next -= 1
        
        return next
    }

    func saveTransaction() {
        transaction.save() { result in
            switch result {
            case .failure(let error):
                fatalError(error.localizedDescription)
            case .success(let updateTrxResponse):
                let trx = Transaction(trx: updateTrxResponse.transaction)

                // If the transaction has no categories assigned and the
                // current category is not the unassigned category
                // OR if the transation has categories and non of them
                // match the current category then remove the transaction
                // from the transactions array
                if let category = category {
                    if ((trx.categories.count == 0 && category.type != .unassigned) || (trx.categories.count != 0 && !trx.hasCategory(categoryId: category.id))) {
                        
                        // Find the index of the transaction in the transactions array
                        let index = transactions.firstIndex(where: {
                            $0.id == trx.id
                        })
                        
                        // If the index was found then remove the transation from
                        // the transactions array
                        if let index = index {
                            transactions.remove(at: index)
                            
                            // If this is the unassigned category then
                            // set the badge to the new number of transactions
                            if (category.type == .unassigned) {
                                UIApplication.shared.applicationIconBadgeNumber = transactions.count
                            }
                        }
                    }
                }
                
                updateTrxResponse.categories.forEach { cat in
                    categoriesStore.categories.updateBalance(categoryId: cat.id, balance: cat.balance)
                }
            }
        }
    }
    
    var body: some View {
        Form {
            List {
                Section {
                    HStack {
                        Text("Date")
                        Spacer()
                        Text(formatDate(date: trxData.date))
                    }
                    HStack {
                        Text("Name")
                        Spacer()
                        Text(trxData.name)
                    }
                    HStack {
                        Text("Amount")
                        Spacer()
                        AmountView(amount: trxData.amount)
                    }
                    HStack {
                        Text("Institution")
                        Spacer()
                        Text(trxData.institution)
                    }
                    HStack {
                        Text("Account")
                        Spacer()
                        Text(trxData.account)
                    }
                }

                Section(
                    header: Text("Categories"),
                    footer: HStack {
                        Text("Unassigned")
                        Spacer()
                        AmountView(amount: trxData.remaining)
                    }
                        .font(.body)
                ) {
                    ForEach($trxData.categories) { $trxCat in
                        VStack(alignment: .leading) {
                            HStack() {
                                CategoryPicker(selection: $trxCat.categoryId)
                                Spacer()
                                NumericField(value: $trxCat.amount)
                                    .frame(maxWidth: 100)
                            }
                            TextField("Comment", text: $trxCat.comment)
                                .truncationMode(.tail)
                        }
                    }
                    .onDelete { indices in
                        trxData.categories.remove(atOffsets: indices)
                    }
                    
                    Button(action: {
                        var category = Transaction.Category();
                        category.id = TransactionEdit.nextId()
                        category.amount = trxData.remaining
                        trxData.categories.append(category)
                    }) {
                        Text("Add Category")
                            .foregroundColor(Color.accentColor)
                    }
                }
            }
        }
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
                    transaction.update(from: trxData)
                    saveTransaction()
                }
                .disabled(!trxData.isValid)
            }
        }
    }
}

struct TransactionEdit_Previews: PreviewProvider {
    static let isEditingTrx = true
    static let category = Categories.Category(id: 0, groupId: 0, name: "Test", balance: 0, type: .regular, monthlyExpenses: false)

    static var previews: some View {
        TransactionEdit(transaction: .constant(SampleData.transactions[0]), isEditingTrx: .constant(isEditingTrx), trxData: .constant(SampleData.transactions[0].data), transactions: .constant(SampleData.transactions), category: category)
            .previewInterfaceOrientation(.portraitUpsideDown)
    }
}
