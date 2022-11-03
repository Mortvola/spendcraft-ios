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
    @StateObject var trxData = Transaction.Data()
    @ObservedObject var transactionStore: TransactionStore
    let category: SpendCraft.Category?
    @State var newSelection: Int? = nil
    var postedTransaction: Bool
    @State var initialized = false

    static var next: Int = 0

    static func nextCategoryId() -> Int {
        next -= 1
        
        return next
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
                                        category.id = TransactionEdit.nextCategoryId()
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
                        Task {
                            transaction.update(from: trxData)
                            await transaction.save(category: category, transactionStore: transactionStore) {
                                // If this is the unassigned category then
                                // set the badge to the new number of transactions
                                if let category = category, category.type == .unassigned {
                                    UIApplication.shared.applicationIconBadgeNumber = transactionStore.transactions.count
                                }
                            }
                            isEditingTrx = false;
                        }
                    }
                    .disabled(!trxData.isValid || !postedTransaction)
                }
            }
            .task() {
                if !initialized {
                    let data = await transaction.data()
                    trxData.update(from: data)
                    initialized = true
                    print("test")
                }
            }
        }
    }
}

struct TransactionEdit_Previews: PreviewProvider {
    static let isEditingTrx = true
    static let category = SpendCraft.Category(id: 0, groupId: 0, name: "Test", balance: 0, type: .regular, monthlyExpenses: false, hidden: false)
    static let transactionStore = TransactionStore();
    static let postedTransaction = true

    static var previews: some View {
        TransactionEdit(transaction: SampleData.transactions[0], isEditingTrx: .constant(isEditingTrx), transactionStore: transactionStore, category: category, postedTransaction: postedTransaction)
            .previewInterfaceOrientation(.portraitUpsideDown)
    }
}
