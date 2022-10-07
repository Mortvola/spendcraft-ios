//
//  RegisterView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/16/22.
//

import SwiftUI

struct RegisterView: View {
    @ObservedObject var category: Categories.Category
    @EnvironmentObject var categoriesStore: CategoriesStore
    @StateObject private var store = TransactionStore();
    @State var loading = false

    func loadTransactions() {
        TransactionStore.load(category: category) { result in
            switch result {
            case .failure(let error):
                fatalError(error.localizedDescription)
            case .success(let transactionsResponse):
                var runningBalance = transactionsResponse.balance;

                let transactions: [Transaction] = transactionsResponse.transactions.map {
                    var trx = Transaction(trx: $0)
                    trx.runningBalance = runningBalance
                    runningBalance -= trx.categoryAmount(category: category)
                    return trx;
                }
            
                self.store.transactions = transactions
                categoriesStore.categories.updateBalance(categoryId: category.id, balance: transactionsResponse.balance)
                
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
                List($store.transactions) { $trx in
                    TransactionView(trx: $trx, transactions: $store.transactions, category: category)
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
    static let category = Categories.Category(id: 0, groupId: 0, name: "Test Category", balance: 100, type: .regular, monthlyExpenses: true)

    static var previews: some View {
        RegisterView(category: category)
    }
}
