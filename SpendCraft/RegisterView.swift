//
//  RegisterView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/16/22.
//

import SwiftUI

struct RegisterView: View {
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
        .navigationTitle("Unassigned")
        .onAppear {
            TransactionStore.load() { result in
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
    static var previews: some View {
        RegisterView()
    }
}
