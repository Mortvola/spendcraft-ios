//
//  RegisterView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/16/22.
//

import SwiftUI

struct RegisterView: View {
    @Binding var category: Category
    @StateObject private var store = TransactionStore();

    var body: some View {
        List {
            ForEach($store.transactions) { $trx in
                NavigationLink(destination: TransactionDetailView(transaction: $trx)) {
                    TransactionView(transaction: trx)
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle(category.name)
        .onAppear {
            TransactionStore.load(category: category) { result in
                switch result {
                case .failure(let error):
                    fatalError(error.localizedDescription)
                case .success(let transactions):
                    self.store.transactions = transactions
                }
            }
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static let category = Category(id: 0, groupId: 0, name: "Test Category", balance: 100, type: "REGULAR", monthlyExpenses: true)
    static var previews: some View {
        RegisterView(category: .constant(category))
    }
}
