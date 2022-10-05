//
//  Transaction.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/16/22.
//

import Foundation

struct Transaction: Identifiable, Codable {
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
        
        init(trxCategory: TransactionResponse.TransactionCategory) {
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
    
    init(id: Int, date: String, name: String, amount: Double, institution: String, account: String, comment: String?, transactionCategories: [Category]) {
        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "y-M-d"
        
        self.id = id
        self.date = dateFormatter.date(from: date)
        self.name = name
        self.amount = amount
        self.institution = institution
        self.account = account
        self.accountOwner = ""
        self.comment = comment
        self.categories = transactionCategories
    }
    
    init(trx: TransactionResponse) {
        self.id = trx.id
        self.date = trx.date
        self.comment = trx.comment
        self.name = trx.accountTransaction?.name ?? ""
        self.amount = trx.accountTransaction?.amount ?? 0
        self.institution = trx.accountTransaction?.account.institution.name ?? ""
        self.account = trx.accountTransaction?.account.name ?? ""
        self.accountOwner = trx.accountTransaction?.accountOwner?.capitalized ?? ""
        self.categories = trx.transactionCategories.map {
            Category(trxCategory: $0)
        }
    }
    
    func hasCategory(categoryId: Int) -> Bool {
        categories.contains {
            $0.id == categoryId
        }
    }
    
    func categoryAmount(category: Categories.Category) -> Double {
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

    func save(completion: @escaping (Result<UpdateTransactionResponse, Error>)->Void) {
        guard let url = getUrl(path: "/api/transaction/\(self.id)") else {
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PATCH"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        guard let session = try? getSession() else {
            return
        }

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

        guard let uploadData = try? JSONEncoder().encode(trxData) else {
            return
        }

        let task = session.uploadTask(with: urlRequest, from: uploadData) {data, response, error in
            if let error = error {
                print("Error: \(error)");
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                print ("response is nil")
                return
            }
            
            guard (200...299).contains(response.statusCode) else {
                print ("Server error: \(response.statusCode)")
                return
            }
            
            print("success: \(response.statusCode)")
            
            guard let data = data else {
                print ("data is nil")
                return
            }
            
            var updateTrxResponse: UpdateTransactionResponse
            do {
                updateTrxResponse = try JSONDecoder().decode(UpdateTransactionResponse.self, from: data)
            }
            catch {
                print ("Error: \(error)")
                return
            }

            DispatchQueue.main.async {
                completion(.success(updateTrxResponse))
            }
        }
        task.resume()
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
    
    mutating func update(from data: Data) {
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
