//
//  Store.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/18/22.
//

import Foundation
import Framework
import Http

enum TransactionContainer: Equatable {
    static func == (lhs: TransactionContainer, rhs: TransactionContainer) -> Bool {
        switch(lhs) {
        case .category(let lhsCat, let lhsState):
            switch(rhs) {
            case .category(let rhsCat, let rhsState):
                return lhsCat === rhsCat && lhsState == rhsState
            case .account:
                return false
            }
        case .account(let lhsAccount, let lhsState):
            switch(rhs) {
            case .category:
                return false
            case .account(let rhsAccount, let rhsState):
                return lhsAccount === rhsAccount && lhsState == rhsState
            }
        }
    }
    
    case category(SpendCraft.Category, TransactionState)
    case account(Account, TransactionState)
}

class TransactionStore: ObservableObject {
    @Published var transactionContainer: TransactionContainer?
    @Published var transactions: [Trx] = []
    @Published var loading = false

    static public let shared = TransactionStore()

    @MainActor
    public func loadTransactions(category: SpendCraft.Category, transactionState: TransactionState, clear: Bool = false) async {
        self.transactionContainer = .category(category, transactionState)

        if clear {
            self.transactions = []
        }

        if transactionState == TransactionState.Posted {
            await loadPosted(path: "/api/v1/category/\(category.id)/transactions?offset=0&limit=30", container: .category(category, .Posted))

            // Update the badge if the current category is the unassigned category.
            if (category.type == .unassigned) {
//                UIApplication.shared.applicationIconBadgeNumber = transactionStore.transactions.count
            }
        } else {
            await loadPending(category: category)
        }
    }

    @MainActor
    public func loadTransactions(account: Account, transactionState: TransactionState, clear: Bool = false) async {
        self.transactionContainer = .account(account, transactionState)

        if clear {
            self.transactions = []
        }

        if transactionState == TransactionState.Posted {
            await loadPosted(path: "/api/v1/account/\(account.id)/transactions?offset=0&limit=30", container: .account(account, .Posted))
        }
        else {
            await loadPending(account: account)
        }
    }

    @MainActor
    private func loadPosted(path: String, container: TransactionContainer) async {
        self.loading = true
        
        if let transactionsResponse: Http.Response<Response.Transactions> = try? await Http.get(path: path) {
            if let transactionsResponse = transactionsResponse.data {
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
                
                if container == self.transactionContainer {
                    self.transactions = transactions
                    
                    switch(container) {
                    case .category(let category, _):
                        CategoriesStore.shared.updateBalance(categoryId: category.id, balance: transactionsResponse.balance)
                    case .account:
                        break
                    }
                }
            }
        }

        self.loading = false
    }

    @MainActor
    private func loadPending(account: Account) async {
        self.loading = true
        
        if let pendingResponse: Http.Response<[Response.Transaction]> = try? await Http.get(path: "/api/v1/account/\(account.id)/transactions/pending?offset=0&limit=30") {
            if let pendingResponse = pendingResponse.data {
                let transactions: [Trx] = pendingResponse.map {
                    switch $0.type {
                    case .funding:
                        return FundingTransaction(trx: $0)
                    default:
                        return Transaction(trx: $0)
                    }
                }
                
                if TransactionContainer.account(account, .Pending) == self.transactionContainer {
                    self.transactions = transactions
                }
            }
        }

        self.loading = false
    }

    @MainActor
    private func loadPending(category: SpendCraft.Category) async {
        self.loading = true
        
        if let pendingResponse: Http.Response<[Response.Transaction]> = try? await Http.get(path: "/api/v1/category/\(category.id)/transactions/pending?offset=0&limit=30") {
            if let pendingResponse = pendingResponse.data {
                let transactions = pendingResponse.map {
                    Transaction(trx: $0)
                }
                
                
                if TransactionContainer.category(category, .Pending) == self.transactionContainer {
                    self.transactions = transactions
                }
            }
        }
        
        self.loading = false
    }

    @MainActor
    static func sync(account: Account) async {
        if let institution = account.institution {
            if let accountSync: Http.Response<Response.AccountSync> = try? await Http.post(path: "/api/v1/institution/\(institution.id)/accounts/\(account.id)/transactions/sync") {
                if let accountSync = accountSync.data {
                    account.balance = accountSync.accounts[0].balance
                    account.syncDate = accountSync.accounts[0].syncDate
                }
            }
        }
    }
}
