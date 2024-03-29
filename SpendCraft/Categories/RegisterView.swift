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
    @ObservedObject private var transactionStore = TransactionStore.shared;
    @EnvironmentObject private var navModel: NavModel
    @State var stateSelection = TransactionState.Posted

    var transactionState: TransactionState {
        if category == CategoriesStore.shared.unassigned {
            return navModel.transactionState
        }
        
        return TransactionState.Posted
    }

    var body: some View {
        VStack {
            if category.type == .unassigned {
                TransactionTypePicker(transactionState: $stateSelection)
                    .onChange(of: stateSelection) { newValue in
                        navModel.transactionState = newValue
                        Task {
                            await transactionStore.loadTransactions(category: category, transactionState: transactionState)
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
                    // Make sure the list of transactionw we have in the store are
                    // what we are supposed to display in this view.
                    List(transactionStore.transactionContainer == .category(category, transactionState) ? transactionStore.transactions : []) { trx in
                        switch trx.type {
                        case .funding:
                            FundingTransactionView(trx: trx as! FundingTransaction, category: category, postedTransaction: navModel.transactionState == TransactionState.Posted)
                        default:
                            TransactionView(trx: trx as! Transaction, category: category, postedTransaction: navModel.transactionState == TransactionState.Posted)
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        await transactionStore.loadTransactions(category: category, transactionState: transactionState)
                    }
                }
            }
        }
        .navigationTitle(category.name)
        .task {
            stateSelection = transactionState
            await transactionStore.loadTransactions(category: category, transactionState: transactionState)
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static let category = SpendCraft.Category(id: 0, groupId: 0, name: "Test Category", balance: 100, type: .regular, monthlyExpenses: true, hidden: false)

    static var previews: some View {
        RegisterView(category: category)
    }
}
