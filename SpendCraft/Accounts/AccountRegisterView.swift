//
//  AccountRegisterView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/30/22.
//

import SwiftUI

struct AccountRegisterView: View {
    @Binding var institution: Institution
    @Binding var account: Account
    @StateObject private var store = TransactionStore();

    func loadTransactions() {
        TransactionStore.load(account: account) { result in
            switch result {
            case .failure(let error):
                fatalError(error.localizedDescription)
            case .success(let transactionsResponse):
                var runningBalance = transactionsResponse.balance;
                
                let transactions: [Transaction] = transactionsResponse.transactions.map {
                    var trx = Transaction(trx: $0)
                    trx.runningBalance = runningBalance
                    runningBalance -= trx.amount

                    return trx
                }
            
                self.store.transactions = transactions
            }
        }
    }

    var body: some View {
        List($store.transactions) {
            AccountTransactionView(trx: $0)
        }
        .listStyle(.plain)
        .navigationTitle(account.name)
        .refreshable {
            loadTransactions()
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(action: {
                    TransactionStore.sync(institution: institution, account: account) { result in
                        switch result {
                        case .failure(let error):
                            fatalError(error.localizedDescription)
                        case .success(let syncResponse):
                            account.balance = syncResponse.accounts[0].balance
                            account.syncDate = syncResponse.accounts[0].syncDate
                        }
                    }
                }) {
                    Image(systemName: "arrow.triangle.2.circlepath")
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
        AccountRegisterView(institution: .constant(institution), account: .constant(institution.accounts[0]))
    }
}
