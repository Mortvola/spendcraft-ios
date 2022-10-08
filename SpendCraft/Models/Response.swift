//
//  Response.swift
//  SpendCraft
//
//  Created by Richard Shields on 10/5/22.
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

struct Response {
    struct AccountSync: Decodable {
        struct Category: Decodable {
            var id: Int
            var balance: Double
        }
        
        struct Account: Codable {
            var id: Int
            var balance: Double
            var plaidBalance: Double
            var syncDate: Date
            
            public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                
                self.id = try container.decode(Int.self, forKey: .id)
                self.balance = try container.decode(Double.self, forKey: .balance)
                self.plaidBalance = try container.decode(Double.self, forKey: .plaidBalance)
                
                // Decode date format of 2022-01-31T14:03:42.384+00:00
                let dateString = try container.decode(String?.self, forKey: .syncDate)
                guard let dateString = dateString else {
                    throw MyError.runtimeError("syncDate not set")
                }
                
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                
                guard let date = formatter.date(from: dateString) else {
                    throw MyError.runtimeError("syncData is not valid")
                }
                
                self.syncDate = date;
            }
        }
        
        var categories: [Category]
        var accounts: [Account]
    }
    
    struct Transaction: Codable {
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
        var type: TransactionType
        
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
            
            self.type = try container.decode(TransactionType.self, forKey: .type)
            
            do {
                self.accountTransaction = try container.decodeIfPresent(AccountTransaction.self, forKey: .accountTransaction)
            }
            catch {
                print("error decoding accountTransaction")
            }
            
            do {
                self.transactionCategories = try container.decode([TransactionCategory].self, forKey: .transactionCategories)
            }
            catch {
                self.transactionCategories = []
            }
        }
    }
    
    struct Transactions: Codable {
        var transactions: [Response.Transaction]
        var balance: Double
    }
    
    struct UpdateTransaction: Codable {
        struct Category: Codable {
            var id: Int
            var balance: Double
        }
        
        var categories: [Category]
        var transaction: Response.Transaction
    }
    
    struct Account: Codable {
        var id: Int
        var name: String
        var balance: Double
        var closed: Bool
        var syncDate: Date?
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.id = try container.decode(Int.self, forKey: .id)
            self.name = try container.decode(String.self, forKey: .name)
            self.balance = try container.decode(Double.self, forKey: .balance)
            self.closed = try container.decode(Bool.self, forKey: .closed)
            
            // Decode date format of 2022-01-31T14:03:42.384+00:00
            let dateString = try container.decode(String?.self, forKey: .syncDate)
            if let dateString = dateString {
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                if let date = formatter.date(from: dateString) {
                    self.syncDate = date;
                }
                else {
                    print("date is invalid: \(dateString)")
                }
            }
        }
    }
    
    struct Institution: Decodable {
        var id: Int
        var name: String
        var accounts: [Account]
    }
    
    class Category: Decodable, Identifiable {
        var id: Int
        var groupId: Int
        var name: String
        var balance: Double
        var type: CategoryType
        var monthlyExpenses: Bool
        
        init(id: Int, groupId: Int, name: String, balance: Double, type: String, monthlyExpenses: Bool) {
            self.id = id
            self.groupId = groupId
            self.name = name
            self.balance = balance
            self.type = CategoryType(type: type)
            self.monthlyExpenses = monthlyExpenses
        }
    }

    class Group: Decodable, Identifiable {
        var id: Int
        var name: String
        var type: GroupType
        var categories: [Category]
        
        init(id: Int, name: String, type: String, categories: [Category]) {
            self.id = id
            self.name = name
            self.type = GroupType(type: type)
            self.categories = categories
        }
    }

    enum CategoryTreeNode: Decodable, Identifiable {
        case group(Response.Group)
        case category(Response.Category)
        
        var id: String {
            switch self {
            case .category(let category):
                return String("Cat-\(category.id)")
            case .group(let group):
                return String("Grp-\(group.id)")
            }
        }
        
        var name: String {
            switch self {
            case .category(let category):
                return category.name
            case .group(let group):
                return group.name
            }
        }
        
        var children: [CategoryTreeNode]? {
            switch self {
            case .category:
                return nil
            case .group(let group):
                return group.categories.map{
                    CategoryTreeNode.category($0)
                }
            }
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            
            do {
                let category = try container.decode(Response.Category.self)
                self = .category(category)
                return
            }
            catch {
            }
            
            do {
                let group = try container.decode(Response.Group.self)
                self = .group(group)
                return
            }
            catch {
            }
            
            throw MyError.runtimeError("Failed to decode tree node")
        }
    }
}

extension CategoryType: Decodable {
    init(from decoder: Decoder) {
        do {
            let container = try decoder.singleValueContainer()
            let type = try container.decode(String.self)
            
            self = CategoryType(type: type)
        }
        catch {
            self = .unknown
        }
    }
}

extension GroupType: Decodable {
    init(from decoder: Decoder) {
        do {
            let container = try decoder.singleValueContainer()
            let type = try container.decode(String.self)
            
            self = GroupType(type: type)
        }
        catch {
            self = .unknown
        }
    }
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
