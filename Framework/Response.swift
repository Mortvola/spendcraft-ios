//
//  Response.swift
//  SpendCraft
//
//  Created by Richard Shields on 10/5/22.
//

import Foundation

extension SpendCraft {
    public enum Response {
        public class Category: Decodable, Identifiable {
            public var id: Int
            public var groupId: Int
            public var name: String
            public var balance: Double
            public var type: CategoryType
            public var monthlyExpenses: Bool
        }
        
        public class Group: Decodable, Identifiable {
            public var id: Int
            public var name: String
            public var type: GroupType
            public var categories: [Category]
        }
        
        public enum CategoryTreeNode: Decodable, Identifiable {
            case group(Response.Group)
            case category(Response.Category)
            
            public var id: String {
                switch self {
                case .category(let category):
                    return String("Cat-\(category.id)")
                case .group(let group):
                    return String("Grp-\(group.id)")
                }
            }
            
            public init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                
                let category = try? container.decode(Response.Category.self)
                if let category = category {
                    self = .category(category)
                    return
                }
                
                let group = try? container.decode(Response.Group.self)
                if let group = group {
                    self = .group(group)
                    return
                }
                
                throw MyError.runtimeError("Failed to decode tree node")
            }
        }
    }
}
