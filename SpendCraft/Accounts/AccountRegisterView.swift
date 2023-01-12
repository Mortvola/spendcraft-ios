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

    var body: some View {
        VStack {
            TransactionTypePicker(transactionState: $account.transactionState)
                .onChange(of: account.transactionState) { _ in
                    transactionStore.loading = true
                    Task {
                        await transactionStore.loadTransactions(account: account, transactionState: account.transactionState)
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
                    // Make sure the list of transactionw we have in the store are
                    // what we are supposed to display in this view.
                    List(transactionStore.transactionContainer == .account(account, account.transactionState) ? transactionStore.transactions : []) {
                        AccountTransactionView(trx: $0 as! Transaction, postedTransaction: account.transactionState == TransactionState.Posted)
                    }
                    .listStyle(.plain)
                    .navigationTitle(account.name)
                    .refreshable {
                        await transactionStore.loadTransactions(account: account, transactionState: account.transactionState)
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
            await transactionStore.loadTransactions(account: account, transactionState: account.transactionState)
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
