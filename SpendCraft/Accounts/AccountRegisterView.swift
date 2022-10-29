//
//  AccountRegisterView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/30/22.
//

import SwiftUI

struct AccountRegisterView: View {
    @ObservedObject var account: Account
    @StateObject private var transactionStore = TransactionStore();
    var animation: Animation {
        .linear(duration: 2.0)
        .repeatForever(autoreverses: false)
    }
    @State var syncing: Bool = false
    @State var transactionType: Int = 0

    func loadTransactions() async {
        if transactionType == 0 {
            await transactionStore.load(account: account)
        }
        else {
            await self.transactionStore.loadPending(account: account)
        }
    }

    var body: some View {
        VStack {
            TransactionTypePicker(transactionType: $transactionType)
                .onChange(of: transactionType) { _ in
                    transactionStore.loading = true
                    Task {
                        await loadTransactions()
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
                    List(transactionStore.transactions) {
                        AccountTransactionView(trx: $0, transactionStore: transactionStore, postedTransaction: transactionType == 0)
                    }
                    .listStyle(.plain)
                    .navigationTitle(account.name)
                    .refreshable {
                        await loadTransactions()
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
            await loadTransactions()
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
