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
        VStack(alignment: .leading) {
            Text("Unassigned")
                .font(.title)
            List {
                ForEach(store.transactions) { trx in
                    TransactionView(transaction: trx)
                }
            }
            .listStyle(.plain)
        }
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
