//
//  RegisterView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/16/22.
//

import SwiftUI

struct RegisterView: View {
    @ObservedObject var category: Categories.Category
    @Binding var categories: Categories
    @StateObject private var store = TransactionStore();
    @State var loading = false
    
    func loadTransactions() {
        TransactionStore.load(category: category) { result in
            switch result {
            case .failure(let error):
                fatalError(error.localizedDescription)
            case .success(let transactionsResponse):
                let transactions: [Transaction] = transactionsResponse.transactions.map {
                    Transaction(trx: $0)
                }
            
                self.store.transactions = transactions
                categories.updateBalance(categoryId: category.id, balance: transactionsResponse.balance)
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
                List($store.transactions) {
                    TransactionView(trx: $0, transactions: $store.transactions, category: category, categories: $categories)
                }
                .listStyle(.plain)
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
        RegisterView(category: category, categories: .constant(SampleData.categories))
    }
}
