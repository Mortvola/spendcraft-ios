//
//  Response.swift
//  SpendCraft
//
//  Created by Richard Shields on 10/5/22.
//

import Foundation

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
}
