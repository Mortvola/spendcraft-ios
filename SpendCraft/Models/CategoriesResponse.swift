//
//  CategoriesResponse.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/19/22.
//

import Foundation

struct Category: Codable, Identifiable {
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

struct Group: Codable, Identifiable {
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

enum CategoryTreeNode: Codable, Identifiable {
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
            print ("Not a category")
        }
        
        do {
            let group = try container.decode(Group.self)
            self = .group(group)
            return
        }
        catch {
            print ("Not a group")
        }
        
        throw MyError.runtimeError("Failed to decode tree node")
    }
}
