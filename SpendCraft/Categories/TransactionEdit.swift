//
//  TransactionDetailView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/18/22.
//

import SwiftUI
import WidgetKit
import Framework

struct TransactionEdit: View {
    @ObservedObject var transaction: Transaction
    @Binding var isEditingTrx: Bool
    @Binding var trxData: Transaction.Data
    @ObservedObject var transactionStore: TransactionStore
    let category: SpendCraft.Category?
    var categoriesStore = CategoriesStore.shared
    static var next: Int = 0
    @State var newSelection: Int? = nil
    var postedTransaction: Bool

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
                        let index = transactionStore.transactions.firstIndex(where: {
                            $0.id == trx.id
                        })
                        
                        // If the index was found then remove the transation from
                        // the transactions array
                        if let index = index {
                            transactionStore.transactions.remove(at: index)
                            
                            // If this is the unassigned category then
                            // set the badge to the new number of transactions
                            if (category.type == .unassigned) {
                                UIApplication.shared.applicationIconBadgeNumber = transactionStore.transactions.count
                            }
                        }
                    }
                }
                
                if (updateTrxResponse.categories.count > 0) {
                    updateTrxResponse.categories.forEach { cat in
                        categoriesStore.updateBalance(categoryId: cat.id, balance: cat.balance)
                    }
                    
                    categoriesStore.write()
                }
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                List {
                    Section {
                        LabeledContent("Date") {
                            Text(formatDate(date: trxData.date))
                        }
                        LabeledContent("Name") {
                            Text(trxData.name)
                        }
                        LabeledContent("Amount") {
                            SpendCraft.AmountView(amount: trxData.amount)
                        }
                        LabeledContent("Institution") {
                            Text(trxData.institution)
                        }
                        LabeledContent("Account") {
                            Text(trxData.account)
                        }
                    }

                    if postedTransaction {
                        Section(
                            header: Text("Categories"),
                            footer: LabeledContent("Unassigned") {
                                SpendCraft.AmountView(amount: trxData.remaining)
                            }
                                .font(.body)
                        ) {
                            ForEach($trxData.categories) { $trxCat in
                                VStack(alignment: .leading) {
                                    HStack() {
                                        CategoryPicker(selection: $trxCat.categoryId)
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
                            CategoryPicker(selection: $newSelection)
                                .onChange(of: newSelection) { id in
                                    if let id = id {
                                        var category = Transaction.Category();
                                        category.id = TransactionEdit.nextId()
                                        category.categoryId = id
                                        category.amount = trxData.remaining
                                        trxData.categories.append(category)
                                        newSelection = nil
                                    }
                                }
                        }
                    }
                }
            }
            .navigationTitle(postedTransaction ? "Edit Transaction" : "Pending Transaction")
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
                    .disabled(!trxData.isValid || !postedTransaction)
                }
            }
        }
    }
}

struct TransactionEdit_Previews: PreviewProvider {
    static let isEditingTrx = true
    static let category = SpendCraft.Category(id: 0, groupId: 0, name: "Test", balance: 0, type: .regular, monthlyExpenses: false)
    static let transactionStore = TransactionStore();
    static let postedTransaction = true

    static var previews: some View {
        TransactionEdit(transaction: SampleData.transactions[0], isEditingTrx: .constant(isEditingTrx), trxData: .constant(SampleData.transactions[0].data), transactionStore: transactionStore, category: category, postedTransaction: postedTransaction)
            .previewInterfaceOrientation(.portraitUpsideDown)
    }
}
