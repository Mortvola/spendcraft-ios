//
//  Store.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/18/22.
//

import Foundation
import Framework
import Http

class TransactionStore: ObservableObject {
    @Published var transactions: [Trx] = []
    @Published var loading = false

    static public let shared = TransactionStore()

    public func loadTransactions(category: SpendCraft.Category, transactionState: TransactionState, clear: Bool = false) async {
        if clear {
            self.transactions = []
        }

        if transactionState == TransactionState.Posted {
            await load(category: category)

            // Update the badge if the current category is the unassigned category.
            if (category.type == .unassigned) {
//                UIApplication.shared.applicationIconBadgeNumber = transactionStore.transactions.count
            }
        } else {
            await loadPending(category: category)
        }
    }

    public func loadTransactions(account: Account, transactionState: TransactionState, clear: Bool = false) async {
        if clear {
            self.transactions = []
        }

        if transactionState == TransactionState.Posted {
            await load(account: account)
        }
        else {
            await loadPending(account: account)
        }
    }

    @MainActor
    private func load(path: String, categoryId: Int? = nil) async {
        loading = true
        
        if let transactionsResponse: Response.Transactions = try? await Http.get(path: path) {
            var runningBalance = transactionsResponse.balance;
            
            let transactions: [Trx] = transactionsResponse.transactions.map {
                var trx: Trx

                switch $0.type {
                case .funding:
                    trx = FundingTransaction(trx: $0)
                default:
                    trx = Transaction(trx: $0)
                }
                
                trx.runningBalance = runningBalance
                runningBalance -= trx.amount
                
                return trx
            }
            
            self.transactions = transactions
            
            if let categoryId = categoryId {
                CategoriesStore.shared.updateBalance(categoryId: categoryId, balance: transactionsResponse.balance)
            }
        }

        loading = false
    }

    @MainActor
    private func loadPending(account: Account) async {
        self.loading = true
        
        if let pendingResponse: [Response.Transaction] = try? await Http.get(path: "/api/account/\(account.id)/transactions/pending?offset=0&limit=30") {
            let transactions: [Trx] = pendingResponse.map {
                switch $0.type {
                case .funding:
                    return FundingTransaction(trx: $0)
                default:
                    return Transaction(trx: $0)
                }
            }
            
            self.transactions = transactions
        }

        self.loading = false
    }

    @MainActor
    private func loadPending(category: SpendCraft.Category) async {
        self.loading = true
        
        if let pendingResponse: [Response.Transaction] = try? await Http.get(path: "/api/category/\(category.id)/transactions/pending?offset=0&limit=30") {
            let transactions = pendingResponse.map {
                Transaction(trx: $0)
            }
            
            self.transactions = transactions
        }
        
        self.loading = false
    }

    private func load(account: Account) async {
        await load(path: "/api/account/\(account.id)/transactions?offset=0&limit=30")
    }

    private func load(category: SpendCraft.Category) async {
        await load(path: "/api/category/\(category.id)/transactions?offset=0&limit=30", categoryId: category.id)
    }
    
    @MainActor
    static func sync(account: Account) async {
        if let institution = account.institution {
            if let accountSync: Response.AccountSync = try? await Http.post(path: "/api/institution/\(institution.id)/accounts/\(account.id)/transactions/sync") {
                account.balance = accountSync.accounts[0].balance
                account.syncDate = accountSync.accounts[0].syncDate
            }
        }
    }
}
