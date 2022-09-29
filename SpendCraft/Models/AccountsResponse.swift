//
//  AccountsResponse.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/29/22.
//

import Foundation

struct AccountResponse: Codable {
    var id: Int
    var name: String
    var balance: Double
    var closed: Bool
    var syncDate: Date?
}

struct InstitutionResponse: Decodable {
    var id: Int
    var name: String
    var accounts: [AccountResponse]
}


extension AccountResponse {
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
