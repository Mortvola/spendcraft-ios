//
//  CategoriesResponse.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/19/22.
//

import Foundation

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
