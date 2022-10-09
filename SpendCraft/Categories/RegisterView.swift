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

    func loadTransactions() {
        TransactionStore.load(category: category) { result in
            switch result {
            case .failure(let error):
                fatalError(error.localizedDescription)
            case .success(let transactionsResponse):
                var runningBalance = transactionsResponse.balance;

                let transactions: [Transaction] = transactionsResponse.transactions.map {
                    let trx = Transaction(trx: $0)
                    trx.runningBalance = runningBalance
                    runningBalance -= trx.categoryAmount(category: category)
                    return trx;
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
    }

    var body: some View {
        VStack {
            if (loading) {
                ProgressView()
                Spacer()
            }
            else {
                List(transactionStore.transactions) { trx in
                    TransactionView(trx: trx, transactionStore: transactionStore, category: category)
                }
                .listStyle(.plain)
                .refreshable {
                    loadTransactions()
                }
            }
        }
        .navigationTitle(category.name)
        .onAppear {
            loading = true
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
