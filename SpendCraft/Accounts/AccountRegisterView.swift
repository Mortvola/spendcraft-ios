//
//  AccountRegisterView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/30/22.
//

import SwiftUI

struct AccountRegisterView: View {
    @ObservedObject var account: Account
    @ObservedObject private var transactionStore = TransactionStore.shared;
    var animation: Animation {
        .linear(duration: 2.0)
        .repeatForever(autoreverses: false)
    }
    @State var syncing: Bool = false
    @EnvironmentObject private var navModel: NavModel

    var body: some View {
        VStack {
            TransactionTypePicker(transactionState: $navModel.transactionState)
                .onChange(of: navModel.transactionState) { _ in
                    transactionStore.loading = true
                    Task {
                        await transactionStore.loadTransactions(account: account, transactionState: navModel.transactionState)
                    }
                }
            
            if (transactionStore.loading) {
                ProgressView()
                Spacer()
            } else {
                if (transactionStore.transactions.count == 0) {
                    Text("There are no transactions to view.")
                    Spacer()
                }
                else {
                    List(transactionStore.transactionSet == TransactionSet.Account ? transactionStore.transactions : []) {
                        AccountTransactionView(trx: $0 as! Transaction, postedTransaction: navModel.transactionState == TransactionState.Posted)
                    }
                    .listStyle(.plain)
                    .navigationTitle(account.name)
                    .refreshable {
                        await transactionStore.loadTransactions(account: account, transactionState: navModel.transactionState)
                    }
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button {
                                syncing = true
                                Task {
                                    await TransactionStore.sync(account: account)
                                    syncing = false
                                }
                            } label: {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .rotationEffect(.degrees(syncing ? 360.0 : 0.0))
                                    .animation(syncing ? animation : .default, value: syncing)
                            }
                        }
                    }
                }
            }
        }
        .task {
            await transactionStore.loadTransactions(account: account, transactionState: navModel.transactionState)
        }
    }
}

struct AccountRegisterView_Previews: PreviewProvider {
    static let institution = Institution(id: 0, name: "Test", accounts: [
        Account(id: 0, name: "Test Account", balance: 100.0, closed: false)
    ])
    
    static var previews: some View {
        AccountRegisterView(account: institution.accounts[0])
    }
}
