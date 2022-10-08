//
//  Transaction.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/16/22.
//

import Foundation
import SpendCraftFramework

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
        self.name = name
        self.name = Transaction.convertName(name: name, type: type)
        self.amount = amount
        self.institution = institution
        self.account = account
        self.accountOwner = ""
        self.comment = comment
        self.categories = transactionCategories
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
    
    func categoryAmount(category: CategoriesStore.Category) -> Double {
        if (category.type == CategoryType.unassigned) {
            return self.amount
        }

        return categories.reduce(0.0, { result, trxCategory in
            if (trxCategory.categoryId == category.id) {
                if let amount = trxCategory.amount {
                    return result + amount
                }
            }
            
            return result
        })
    }

    func save(completion: @escaping (Result<Response.UpdateTransaction, Error>)->Void) {
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

        try? Http.patch(path: "/api/transaction/\(self.id)", data: trxData) { data in
            guard let data = data else {
                print ("data is nil")
                return
            }
            
            var updateTrxResponse: Response.UpdateTransaction
            do {
                updateTrxResponse = try JSONDecoder().decode(Response.UpdateTransaction.self, from: data)
            }
            catch {
                print ("Error: \(error)")
                return
            }

            DispatchQueue.main.async {
                completion(.success(updateTrxResponse))
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

        var isValid: Bool {
            categories.allSatisfy {
                $0.categoryId != nil && $0.amount != nil
            }
            && (categories.count == 0 || remaining == 0)
        }

        var remaining: Double {
            let sum = self.categories.reduce(0.0, { x, y in
                if let amount = y.amount {
                    return x + amount
                }
                
                return x
            })
            
            return ((self.amount - sum) * 100.0).rounded() / 100.0
        }

    }
    
    var data: Data {
        Data(date: date, name: name, amount: amount, institution: institution, account: account, comment: comment, categories: categories)
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
