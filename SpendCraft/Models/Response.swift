//
//  Response.swift
//  SpendCraft
//
//  Created by Richard Shields on 10/9/22.
//

import Foundation
import Framework

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

enum Response {
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
                self.syncDate = try container.decodeFullDateTime(forKey: .syncDate);
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
            self.syncDate = try container.decodeFullDateTimeIfPresent(forKey: .syncDate)
        }
    }
    
    struct Institution: Decodable {
        var id: Int
        var name: String
        var accounts: [Account]
    }
    
    struct Plan: Decodable {
        var id: Int
        var name: String
        var categories: [PlanCategory]
    }
    
    struct PlanCategory: Decodable {
        var id: Int
        var categoryId: Int
        var amount: Double
        var recurrence: Int
        var goalDate: Date?
        var useGoal: Bool

        enum CodingKeys: String, CodingKey {
            case id
            case categoryId
            case amount
            case recurrence
            case goalDate
            case useGoal
        }

        public init(id: Int, categoryId: Int, amount: Double, recurrence: Int, useGoal: Bool, goalDate: Date?) {
            self.id = id
            self.categoryId = categoryId
            self.amount = amount
            self.recurrence = recurrence
            self.useGoal = useGoal
            self.goalDate = goalDate
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.id = try container.decode(Int.self, forKey: .id)
            self.categoryId = try container.decode(Int.self, forKey: .categoryId)
            self.amount = try container.decode(Double.self, forKey: .amount)
            self.recurrence = try container.decodeIfPresent(Int.self, forKey: .recurrence) ?? 1
            self.goalDate = try container.decodeDateIfPresent(forKey: .goalDate)
            self.useGoal = try container.decode(Bool.self, forKey: .useGoal)
        }
    }
}

extension KeyedDecodingContainer {
    func decodeFullDateTime(forKey key: Self.Key) throws -> Date {
        let date = try self.decodeFullDateTimeIfPresent(forKey: key)
        guard let date = date else {
            throw MyError.runtimeError("Key not present: \(key)")
        }
        
        return date;
    }
    
    func decodeFullDateTimeIfPresent(forKey key: Self.Key) throws -> Date? {
        let dateString = try self.decodeIfPresent(String.self, forKey: key)
        guard let dateString = dateString else {
            return nil
        }
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = formatter.date(from: dateString) else {
            throw MyError.runtimeError("Invalid date format")
        }
        
        return date;
    }
    
    func decodeDateIfPresent(forKey key: Self.Key) throws -> Date? {
        let dateString = try self.decodeIfPresent(String.self, forKey: key)
        guard let dateString = dateString else {
            return nil
        }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withDashSeparatorInDate]
        guard let date = formatter.date(from: dateString) else {
            throw MyError.runtimeError("Invalid date format")
        }
        
        return date;
    }
}
