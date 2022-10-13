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
    @State var loading = false

    func loadTransactions() {
        loading = true
        
        if transactionType == 0 {
            TransactionStore.load(account: account) { result in
                switch result {
                case .failure(let error):
                    fatalError(error.localizedDescription)
                case .success(let transactionsResponse):
                    var runningBalance = transactionsResponse.balance;
                    
                    let transactions: [Transaction] = transactionsResponse.transactions.map {
                        let trx = Transaction(trx: $0)
                        trx.runningBalance = runningBalance
                        runningBalance -= trx.amount
                        
                        return trx
                    }
                    
                    self.transactionStore.transactions = transactions
                }

                loading = false
            }
        }
        else {
            TransactionStore.loadPending(account: account) { result in
                switch result {
                case .failure(let error):
                    fatalError(error.localizedDescription)
                case .success(let pendingTrx):
                    let transactions: [Transaction] = pendingTrx.map {
                        Transaction(trx: $0)
                    }
                    
                    self.transactionStore.transactions = transactions
                }

                loading = false
            }
        }
    }

    var body: some View {
        VStack {
            TransactionTypePicker(transactionType: $transactionType)
                .onChange(of: transactionType) { _ in
                    loading = true
                    loadTransactions()
                }
            
            if (loading) {
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
                        loadTransactions()
                    }
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button(action: {
                                syncing = true
                                TransactionStore.sync(account: account) { result in
                                    switch result {
                                    case .failure(let error):
                                        fatalError(error.localizedDescription)
                                    case .success(let syncResponse):
                                        account.balance = syncResponse.accounts[0].balance
                                        account.syncDate = syncResponse.accounts[0].syncDate
                                    }
                                    
                                    syncing = false
                                }
                            }) {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .rotationEffect(.degrees(syncing ? 360.0 : 0.0))
                                    .animation(syncing ? animation : .default, value: syncing)
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            loadTransactions()
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
