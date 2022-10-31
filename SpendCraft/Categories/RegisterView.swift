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
    @StateObject private var transactionStore = TransactionStore();
    @State var transactionType: Int = 0

    func loadTransactions() async {
        if transactionType == 0 {
            await transactionStore.load(category: category)

            // Update the badge if the current category is the unassigned category.
            if (category.type == .unassigned) {
                UIApplication.shared.applicationIconBadgeNumber = transactionStore.transactions.count
            }
        } else {
            await transactionStore.loadPending(category: category)
        }
    }

    var body: some View {
        VStack {
            if category.type == .unassigned {
                TransactionTypePicker(transactionType: $transactionType)
                    .onChange(of: transactionType) { _ in
                        Task {
                            await loadTransactions()
                        }
                    }
            }
            
            if (transactionStore.loading) {
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
                        await loadTransactions()
                    }
                }
            }
        }
        .navigationTitle(category.name)
        .task {
            await loadTransactions()
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static let category = SpendCraft.Category(id: 0, groupId: 0, name: "Test Category", balance: 100, type: .regular, monthlyExpenses: true, hidden: false)

    static var previews: some View {
        RegisterView(category: category)
    }
}
