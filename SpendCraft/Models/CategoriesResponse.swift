//
//  CategoriesResponse.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/19/22.
//

import Foundation

struct Category: Codable, Identifiable, Hashable {
    var id: Int
    var groupId: Int
    var name: String
    var balance: Double
    var type: String
    var monthlyExpenses: Bool
    
    init(id: Int, groupId: Int, name: String, balance: Double, type: String, monthlyExpenses: Bool) {
        self.id = id
        self.groupId = groupId
        self.name = name
        self.balance = balance
        self.type = type
        self.monthlyExpenses = monthlyExpenses
    }
}

struct Group: Codable, Identifiable, Hashable {
    var id: Int
    var name: String
    var type: String
    var categories: [Category]
    
    init(id: Int, name: String, type: String, categories: [Category]) {
        self.id = id
        self.name = name
        self.type = type
        self.categories = categories
    }
}

enum CategoryTreeNode: Codable, Identifiable, Hashable {
    case group(Group)
    case category(Category)
    
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
}

extension CategoryTreeNode {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        do {
            let category = try container.decode(Category.self)
            self = .category(category)
            return
        }
        catch {
        }
        
        do {
            let group = try container.decode(Group.self)
            self = .group(group)
            return
        }
        catch {
        }
        
        throw MyError.runtimeError("Failed to decode tree node")
    }
}
