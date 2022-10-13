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

        public class CategoryUpdate: Decodable, Identifiable {
//            public var id: Int
//            public var groupId: Int
            public var name: String
//            public var balance: Double
//            public var type: CategoryType
            public var monthlyExpenses: Bool
        }

        public class Group: Decodable, Identifiable {
            public var id: Int
            public var name: String
            public var type: GroupType
            public var categories: [Category]

            enum CodingKeys: String, CodingKey {
                case id
                case name
                case type
                case categories
            }

            public required init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                
                self.id = try container.decode(Int.self, forKey: .id)
                self.name = try container.decode(String.self, forKey: .name)
                
                let groupType = try container.decode(String.self, forKey: .type)
                self.type = GroupType(rawValue: groupType) ?? .unknown
                
                self.categories = try container.decodeIfPresent([SpendCraft.Response.Category].self, forKey: .categories) ?? []
            }
        }
        
        public class GroupUpdate: Decodable, Identifiable {
            public var name: String
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
