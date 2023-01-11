//
//  Transaction.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/16/22.
//

import Foundation
import Framework
import Http

enum TransactionType: Int {
    case regular = 0
    case transfer = 1
    case funding = 2
    case rebalance = 3
    case starting = 4
    case manual = 5
    case unknown
}

extension TransactionType: Codable {
    init(from decoder: Decoder) {
        do {
            let container = try decoder.singleValueContainer()
            let type = try container.decode(Int.self)
            
            let t = TransactionType(rawValue: type)
            
            guard let t = t else {
                throw Framework.MyError.runtimeError("Invalid transaction type: \(type)")
            }
            
            self = t
        }
        catch {
            self = .unknown
        }
    }
}

func transactionName(name: String, type: TransactionType) -> String {
    switch type {
    case .regular:
        return name
    case .manual:
        return name
    case .funding:
        return "Category Funding"
    case .rebalance:
        return "Category Rebalance"
    case .starting:
        return "Starting Balance"
    case .transfer:
        return "Category Transfer"
    case .unknown:
        return "Unknown"
    }
}

class Trx: ObservableObject, Codable, Identifiable {
    var id: Int
    var date: Date?
    var name: String
    var amount: Double
    var runningBalance: Double?
    var type: TransactionType
    
    init(type: TransactionType) {
        self.id = -1
        self.date = Date.now
        self.name = transactionName(name: "", type: type)
        self.type = type
        self.amount = 0
    }
    
    init(id: Int, date: Date?, name: String, type: TransactionType, amount: Double) {
        self.id = id
        self.date = date
        self.name = transactionName(name: name, type: type)
        self.type = type
        self.amount = amount
    }
    
    init(id: Int, date: Date?, name: String, amount: Double, runningBalance: Double?, type: TransactionType) {
        self.id = id
        self.date = date
        self.name = transactionName(name: name, type: type)
        self.runningBalance = runningBalance
        self.type = type
        self.amount = amount
    }
    
    func categoryAmount(category: SpendCraft.Category) -> Double {
        0.0
    }
}

final class Transaction: Trx {
    struct Category: Identifiable, Codable {
        var id: Int?
        var categoryId: Int?
        var amount: Double?
        var comment: String
        
        init() {
            self.comment = ""
        }

        init(id: Int, categoryId: Int, amount: Double, comment: String?) {
            self.id = id
            self.categoryId = categoryId
            self.amount = amount
            self.comment = comment ?? ""
        }
        
        init(trxCategory: Response.Transaction.TransactionCategory) {
            self.id = trxCategory.id
            self.categoryId = trxCategory.categoryId
            self.amount = trxCategory.amount
            self.comment = trxCategory.comment ?? ""
        }

        static private var next = 0
        
        static func nextId() -> Int {
            next -= 1
            
            return next
        }
    }
    
    var institution: String
    var account: String
    var accountOwner: String
    var comment: String?
    var categories: [Category] = []
    
    init(id: Int, date: String, name: String, amount: Double, institution: String, account: String, comment: String?, transactionCategories: [Category], type: TransactionType) {
        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "y-M-d"

        self.institution = institution
        self.account = account
        self.accountOwner = ""
        self.comment = comment
        self.categories = transactionCategories

        super.init(id: id, date: dateFormatter.date(from: date), name: name, type: type, amount: amount)
    }
    
    override init(type: TransactionType) {
        self.institution = ""
        self.account = ""
        self.accountOwner = ""
        self.comment = ""
        self.categories = []

        super.init(type: type)
    }
    
    init(trx: Response.Transaction) {
        self.comment = trx.comment
        self.institution = trx.accountTransaction?.account.institution.name ?? ""
        self.account = trx.accountTransaction?.account.name ?? ""
        self.accountOwner = trx.accountTransaction?.accountOwner?.capitalized ?? ""
        self.categories = trx.transactionCategories.map {
            Category(trxCategory: $0)
        }

        super.init(id: trx.id, date: trx.date, name: trx.accountTransaction?.name ?? "", type: trx.type, amount: trx.accountTransaction?.amount ?? 0)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    func hasCategory(categoryId: Int) -> Bool {
        categories.contains {
            $0.id == categoryId
        }
    }
    
    override func categoryAmount(category: SpendCraft.Category) -> Double {
        if (category.type == CategoryType.unassigned) {
            return self.amount
        }

        return categories.reduce(0.0) { result, trxCategory in
            if (trxCategory.categoryId == category.id) {
                if let amount = trxCategory.amount {
                    return result + amount
                }
            }
            
            return result
        }
    }

    @MainActor
    func save(category: SpendCraft.Category?, transactionStore: TransactionStore?, removed: @escaping ()->Void) async {
        struct TrxData: Encodable {
            struct Category: Encodable {
                var id: Int?
                var categoryId: Int?
                var amount: Double?
                var comment: String?
            }
            
            var name: String
            var date: String
            var amount: Double
            var principle: Double
            var comment: String?
            var splits: [Category]
        }

        guard let date = self.date else {
            return
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        let dateString = formatter.string(from: date)

        let trxData = TrxData(
            name: self.name,
            date: dateString,
            amount: self.amount,
            principle: 0,
            comment: self.comment,
            splits: self.categories.map {
                TrxData.Category(id: $0.id, categoryId: $0.categoryId, amount: $0.amount, comment: $0.comment)
            }
        )

        if self.id < 0 {
            // todo: add code to post new transaction
        }
        else {
            if let updateTrxResponse: Response.UpdateTransaction = try? await Http.patch(path: "/api/transaction/\(self.id)", data: trxData) {
                let trx = Transaction(trx: updateTrxResponse.transaction)

                // If the transaction has no categories assigned and the
                // current category is not the unassigned category
                // OR if the transation has categories and none of them
                // match the current category then remove the transaction
                // from the transactions array
                if let category = category, let transactionStore = transactionStore {
                    if ((trx.categories.count == 0 && category.type != .unassigned) || (trx.categories.count != 0 && !trx.hasCategory(categoryId: category.id))) {
                        
                        // Find the index of the transaction in the transactions array
                        let index = transactionStore.transactions.firstIndex(where: {
                            $0.id == trx.id
                        })
                        
                        // If the index was found then remove the transation from
                        // the transactions array
                        if let index = index {
                            transactionStore.transactions.remove(at: index)
                            removed()
                        }
                    }
                }
                
                if (updateTrxResponse.categories.count > 0) {
                    let categoriesStore = CategoriesStore.shared

                    updateTrxResponse.categories.forEach { cat in
                        categoriesStore.updateBalance(categoryId: cat.id, balance: cat.balance)
                    }
                    
                    categoriesStore.write()
                }
            }
        }
    }
}

extension Transaction {
    struct Data {
        var date: Date?
        var name: String = ""
        var amount: Double = 0.0
        var institution: String = ""
        var account: String = ""
        var comment: String?
        var categories: [Category] = []

        var loaded = false
        
        init() {}
        
        init(_ transaction: Transaction) {
            self.date = transaction.date
            self.name = transaction.name
            self.amount = transaction.amount
            self.institution = transaction.institution
            self.account = transaction.account
            self.comment = transaction.comment
            self.categories = transaction.categories
        }
        
        init(date: Date?, name: String, amount: Double, institution: String, account: String, comment: String?, categories: [Category]) {
            self.date = date
            self.name = name
            self.amount = amount
            self.institution = institution
            self.account = account
            self.comment = comment
            self.categories = categories
        }
        
        mutating func update(from data: Transaction.Data) {
            self.date = data.date
            self.name = data.name
            self.amount = data.amount
            self.institution = data.institution
            self.account = data.account
            self.comment = data.comment
            self.categories = data.categories
            
            self.loaded = data.loaded
        }
        
        var isValid: Bool {
            categories.allSatisfy {
                $0.categoryId != nil && $0.amount != nil
            }
            && (categories.count == 0 || remaining == 0)
        }

        var remaining: Double {
            let sum = self.categories.reduce(0.0) { x, y in
                if let amount = y.amount {
                    return x + amount
                }
                
                return x
            }
            
            return ((self.amount - sum) * 100.0).rounded() / 100.0
        }
        
        func trxCategoryIndex(categoryId: Int) -> Int? {
            self.categories.firstIndex {
                $0.categoryId == categoryId
            }
        }
    }
    
    func data() -> Data {
        return Data(self)
    }
    
    func update(from data: Data) {
        categories = data.categories.filter {
            $0.amount != 0
        }
    }
}

func formatDate(date: Date?) -> String {
    guard let date = date else {
        return ""
    }

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd/yy"
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
    return dateFormatter.string(from: date)
}
