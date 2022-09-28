//
//  Categories.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/19/22.
//

import Foundation

struct Categories {
    class Category: ObservableObject, Identifiable {
        var id: Int
        var groupId: Int
        @Published var name: String
        @Published var balance: Double
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

    class Group: ObservableObject, Identifiable {
        var id: Int
        @Published var name: String
        var type: String
        var categories: [Category]
        
        init(id: Int, name: String, type: String, categories: [Category]) {
            self.id = id
            self.name = name
            self.type = type
            self.categories = categories
        }
    }

    enum TreeNode: Identifiable {
        case group(Group)
        case category(Category)
        
        init(node: CategoryTreeNode) {
            switch(node) {
            case .category(let category):
                self = .category(Category(id: category.id, groupId: category.groupId, name: category.name, balance: category.balance, type: category.type, monthlyExpenses: category.monthlyExpenses))
            case .group(let group):
                let cats = group.categories.map {
                    Category(id: $0.id, groupId: $0.groupId, name: $0.name, balance: $0.balance, type: $0.type, monthlyExpenses: $0.monthlyExpenses)
                }
                self = .group(Group(id: group.id, name: group.name, type: group.type, categories: cats))
            }
        }

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
        
        var children: [TreeNode]? {
            switch self {
            case .category:
                return nil
            case .group(let group):
                return group.categories.map{
                    TreeNode.category($0)
                }
            }
        }
    }

    var tree: [TreeNode] = []
    var groupDictionary: Dictionary<Int, Group>
    var categoryDictionary: Dictionary<Int, Category>
    
    init(tree: [CategoryTreeNode]) {
        self.tree = tree.map {
            Categories.TreeNode(node: $0)
        };

        self.groupDictionary = Dictionary()
        self.categoryDictionary = Dictionary()

        // Find nogroup group
        let noGroup = self.tree.first(where: {
            switch($0) {
            case .group(let group):
                return group.type == "NO GROUP"
            case .category:
                return false
            }
        })
        
        if let noGroup = noGroup {
            noGroup.children?.forEach { node in
                self.tree.append(node)
            }
            
            self.tree.removeAll {
                $0.id == noGroup.id
            }

            // With the noGroup group removed and the noGroup categories
            // moved to the top level, resort the top level of the the tree
            self.tree.sort {
                let name0: String = $0.name
                let name1: String = $1.name

                return name0 < name1
            }
        }

        // Add the groups and categories to the dictionaries
        self.tree.forEach { node in
            switch node {
            case .category(let category):
                categoryDictionary.updateValue(category, forKey: category.id)
                break
            case .group(let group):
                groupDictionary.updateValue(group, forKey: group.id)
                group.categories.forEach { category in
                    categoryDictionary.updateValue(category, forKey: category.id)
                }
                break
            }
        }
    }
    
    public func getCategoryName(categoryId: Int) -> String {
        let category = self.categoryDictionary[categoryId]
        
        if let category = category {
            let group = self.groupDictionary[category.groupId]
            
            if let group = group {
                if (group.type == "NO GROUP") {
                    return category.name
                }
                
                return "\(group.name):\(category.name)"
            }

            return category.name
        }

        return "\(categoryId)"
    }
    
    public func updateBalance(categoryId: Int, balance: Double) {
        let category = self.categoryDictionary[categoryId]
        
        if let category = category {
            category.balance = balance
        }
    }
}
