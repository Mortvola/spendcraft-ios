//
//  RegisterView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/16/22.
//

import SwiftUI
import Framework

struct RegisterView: View {
    @ObservedObject var category: SpendCraft.Category
    var categoriesStore = CategoriesStore.shared
    @StateObject private var transactionStore = TransactionStore();
    @State var loading = false
    @State var transactionType: Int = 0

    func loadTransactions() {
        loading = true

        if transactionType == 0 {
            TransactionStore.load(category: category) { result in
                switch result {
                case .failure(let error):
                    fatalError(error.localizedDescription)
                case .success(let transactionsResponse):
                    var runningBalance = transactionsResponse.balance;
                    
                    var transactions: [Transaction] = []
                    
                    if (category.type == .unassigned) {
                        // Don't store a running balance for the unassigned
                        // transactions
                        transactions = transactionsResponse.transactions.map {
                            Transaction(trx: $0)
                        }
                    } else {
                        transactions = transactionsResponse.transactions.map {
                            let trx = Transaction(trx: $0)
                            trx.runningBalance = runningBalance
                            runningBalance -= trx.categoryAmount(category: category)
                            return trx;
                        }
                    }
                    
                    self.transactionStore.transactions = transactions
                    categoriesStore.updateBalance(categoryId: category.id, balance: transactionsResponse.balance)
                    
                    // Update the badge if the current category is the unassigned category.
                    if (category.type == .unassigned) {
                        UIApplication.shared.applicationIconBadgeNumber = transactions.count
                    }
                }
                
                loading = false
            }
        } else {
            TransactionStore.loadPending(category: category) { result in
                switch result {
                case .failure(let error):
                    fatalError(error.localizedDescription)
                case .success(let pendingTrx):
                    let transactions = pendingTrx.map {
                        Transaction(trx: $0)
                    }
                    
                    self.transactionStore.transactions = transactions
                }
                
                loading = false
            }
        }
    }

    var body: some View {
        VStack {
            if category.type == .unassigned {
                TransactionTypePicker(transactionType: $transactionType)
                    .onChange(of: transactionType) { _ in
                        loadTransactions()
                    }
            }
            
            if (loading) {
                ProgressView()
                Spacer()
            }
            else {
                if (transactionStore.transactions.count == 0) {
                    Text("There are no transactions to view.")
                    Spacer()
                }
                else {
                    List(transactionStore.transactions) { trx in
                        TransactionView(trx: trx, transactionStore: transactionStore, category: category, postedTransaction: transactionType == 0)
                    }
                    .listStyle(.plain)
                    .refreshable {
                        loadTransactions()
                    }
                }
            }
        }
        .navigationTitle(category.name)
        .onAppear {
            loadTransactions()
        }
//        .refreshable {
//            loadTransactions()
//        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static let category = SpendCraft.Category(id: 0, groupId: 0, name: "Test Category", balance: 100, type: .regular, monthlyExpenses: true)

    static var previews: some View {
        RegisterView(category: category)
    }
}
