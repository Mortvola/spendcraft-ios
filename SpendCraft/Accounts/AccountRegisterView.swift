//
//  AccountRegisterView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/30/22.
//

import SwiftUI

struct AccountRegisterView: View {
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
        .onAppear {
            loadTransactions()
        }
    }
}

struct AccountRegisterView_Previews: PreviewProvider {
    static let account = Account(id: 0, name: "Test Account", balance: 100.0, closed: false)
    
    static var previews: some View {
        AccountRegisterView(account: .constant(account))
    }
}
