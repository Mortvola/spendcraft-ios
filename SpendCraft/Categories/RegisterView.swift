//
//  RegisterView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/16/22.
//

import SwiftUI

struct RegisterView: View {
    @Binding var category: Category
    let categories: Categories
    @StateObject private var store = TransactionStore();
    @State var loading = false
    
    func loadTransactions() {
        TransactionStore.load(category: category) { result in
            switch result {
            case .failure(let error):
                fatalError(error.localizedDescription)
            case .success(let transactions):
                self.store.transactions = transactions
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
                List {
                    ForEach($store.transactions) { $trx in
                        RegisterTransactionView(trx: $trx, categories: categories)
                    }
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
    static let category = Category(id: 0, groupId: 0, name: "Test Category", balance: 100, type: "REGULAR", monthlyExpenses: true)
    static let categories = Categories(tree: [])

    static var previews: some View {
        RegisterView(category: .constant(category), categories: categories)
    }
}
