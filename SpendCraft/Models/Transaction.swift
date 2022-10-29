//
//  Transaction.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/16/22.
//

import Foundation
import Framework

enum TransactionType: Int {
    case regular = 0
    case transfer = 1
    case funding = 2
    case rebalance = 3
    case starting = 4
    case manual = 5
    case unknown
}

class Transaction: ObservableObject, Identifiable, Codable {
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
    
    var id: Int
    var date: Date?
    var name: String
    var amount: Double
    var runningBalance: Double?
    var institution: String
    var account: String
    var accountOwner: String
    var comment: String?
    var categories: [Category] = []
    var type: TransactionType
    
    init(id: Int, date: String, name: String, amount: Double, institution: String, account: String, comment: String?, transactionCategories: [Category], type: TransactionType) {
        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "y-M-d"
        
        self.id = id
        self.date = dateFormatter.date(from: date)
        self.name = Transaction.convertName(name: name, type: type)
        self.amount = amount
        self.institution = institution
        self.account = account
        self.accountOwner = ""
        self.comment = comment
        self.categories = transactionCategories
        self.type = type
    }
    
    init(type: TransactionType) {
        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "y-M-d"
        
        self.id = -1
        self.date = Date.now
        self.name = ""
        self.name = Transaction.convertName(name: name, type: type)
        self.amount = 0
        self.institution = ""
        self.account = ""
        self.accountOwner = ""
        self.comment = ""
        self.categories = []
        self.type = type
    }
    
    init(trx: Response.Transaction) {
        self.id = trx.id
        self.date = trx.date
        self.comment = trx.comment
        self.name = Transaction.convertName(name: trx.accountTransaction?.name ?? "", type: trx.type)
        self.amount = trx.accountTransaction?.amount ?? 0
        self.institution = trx.accountTransaction?.account.institution.name ?? ""
        self.account = trx.accountTransaction?.account.name ?? ""
        self.accountOwner = trx.accountTransaction?.accountOwner?.capitalized ?? ""
        self.categories = trx.transactionCategories.map {
            Category(trxCategory: $0)
        }
        self.type = trx.type
    }
    
    static func convertName(name: String, type: TransactionType) -> String {
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
    
    func hasCategory(categoryId: Int) -> Bool {
        categories.contains {
            $0.id == categoryId
        }
    }
    
    func categoryAmount(category: SpendCraft.Category) -> Double {
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
    func save(category: SpendCraft.Category?, transactionStore: TransactionStore, removed: @escaping ()->Void) async {
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

        let trxData = TrxData(name: self.name, date: dateString, amount: self.amount, principle: 0, comment: self.comment, splits: self.categories.map {
            TrxData.Category(id: $0.id, categoryId: $0.categoryId, amount: $0.amount, comment: $0.comment)
        })

        if let updateTrxResponse: Response.UpdateTransaction = try? await Http.patch(path: "/api/transaction/\(self.id)", data: trxData) {
            let trx = Transaction(trx: updateTrxResponse.transaction)

            // If the transaction has no categories assigned and the
            // current category is not the unassigned category
            // OR if the transation has categories and none of them
            // match the current category then remove the transaction
            // from the transactions array
            if let category = category {
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

extension Transaction {
    struct Data {
        var date: Date?
        var name: String = ""
        var amount: Double = 0.0
        var institution: String = ""
        var account: String = ""
        var comment: String?
        var categories: [Category] = []
        var allowedToSpend: [AllowedToSpend] = []

        struct AllowedToSpend {
            var categoryId: Int
            var amount: Double?
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
        
        var allowedTotal: Double {
            return self.allowedToSpend.reduce(0.0) { x, y in
                if let amount = y.amount {
                    return x + amount
                }
                
                return x
            }
        }

        var fundingTotal: Double {
            let categoriesStore = CategoriesStore.shared
            return self.categories.reduce(0.0) { x, y in
                if y.categoryId != categoriesStore.fundingPool.id, let amount = y.amount {
                    return x + amount
                }
                
                return x
            }
        }
    }
    
    func data() async -> Data {
        var data = Data(date: date, name: name, amount: amount, institution: institution, account: account, comment: comment, categories: categories)
        
        // Popuulate the category array with the categories not currently in the array
        if type == .funding {
            data.categories = []
            
            let categoriesStore = CategoriesStore.shared
            categoriesStore.categoryDictionary.forEach { entry in
                if data.categories.first(where: { dataCat in
                    dataCat.id == entry.value.id
                }) == nil {
                    let newCat = Transaction.Category(id: Category.nextId(), categoryId: entry.value.id, amount: 0.0, comment: nil)
                    data.categories.append(newCat)
                }
                
                data.allowedToSpend.append(Data.AllowedToSpend(categoryId: entry.value.id, amount: 0.0))
            }
            
            if let planResponse: Response.Plan = try? await Http.get(path: "/api/funding-plans/10/details") {
                planResponse.categories.forEach { planCat in
                    let i = data.categories.firstIndex {
                        $0.categoryId == planCat.categoryId
                    }
                    
                    if let i = i {
                        data.categories[i].amount = planCat.amount / Double(planCat.recurrence)
                        
                        if planCat.goalDate == nil {
                            let j = data.allowedToSpend.firstIndex {
                                $0.categoryId == planCat.categoryId
                            }
                            
                            if let j = j {
                                if let c = categoriesStore.categoryDictionary[data.allowedToSpend[j].categoryId] {
                                    let balance = c.balance + (planCat.amount / Double(planCat.recurrence))
                                    data.allowedToSpend[j].amount = balance > 0 ? balance : 0
                                }
                            }
                        }
                    }
                }
            }
        }

        return data
    }
    
    func update(from data: Data) {
        categories = data.categories
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

extension TransactionType: Codable {
    init(from decoder: Decoder) {
        do {
            let container = try decoder.singleValueContainer()
            let type = try container.decode(Int.self)
            
            let t = TransactionType(rawValue: type)
            
            guard let t = t else {
                throw MyError.runtimeError("Invalid transaction type: \(type)")
            }
            
            self = t
        }
        catch {
            self = .unknown
        }
    }
}
