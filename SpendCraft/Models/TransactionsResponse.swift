//
//  TransactionResponse.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/18/22.
//

import Foundation

extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

struct TransactionResponse: Codable {
    struct AccountTransaction: Codable {
        struct Account: Codable {
            struct Institution: Codable {
                var name: String
            }
            
            var name: String
            var institution: Institution
        }

        var name: String
        var amount: Double
        var account: Account
        var accountOwner: String?
    }
    
    struct TransactionCategory: Codable {
        var id: Int
        var categoryId: Int
        var amount: Double
        var comment: String?
    }
    
    var id: Int
    var date: Date
    var comment: String?
    var accountTransaction: AccountTransaction?
    var transactionCategories: [TransactionCategory]
}

struct TransactionsResponse: Codable {
    var transactions: [TransactionResponse]
    var balance: Double
}

struct UpdateTransactionResponse: Codable {
    struct Category: Codable {
        var id: Int
        var balance: Double
    }

    var categories: [Category]
    var transaction: TransactionResponse
}

extension TransactionResponse {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int.self, forKey: .id)
        
        let dateString = try container.decode(String.self, forKey: .date)
        let formatter = DateFormatter.yyyyMMdd
        if let date = formatter.date(from: dateString) {
            self.date = date;
        }
        else {
            throw MyError.runtimeError("date is invalid")
        }
        
        do {
            self.accountTransaction = try container.decode(AccountTransaction.self, forKey: .accountTransaction)
        }
        catch {
            print("accountTransaction decoding failed")
        }
        
        do {
            self.transactionCategories = try container.decode([TransactionCategory].self, forKey: .transactionCategories)
        }
        catch {
            self.transactionCategories = []
        }
    }
}
