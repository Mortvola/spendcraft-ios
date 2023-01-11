//
//  CategoriesStore.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/19/22.
//

import Foundation
import Combine
import WidgetKit
import Framework
import Http

extension FileManager {
  static func sharedContainerURL() -> URL {
    return FileManager.default.containerURL(
      forSecurityApplicationGroupIdentifier: "group.app.spendcraft"
    )!
  }
}

final class CategoriesStore: ObservableObject {    
    @Published var tree: [SpendCraft.TreeNode] = []
    @Published var unassigned: SpendCraft.Category
    @Published var fundingPool: SpendCraft.Category
    @Published var accountTransfer: SpendCraft.Category
    var noGroupId: Int
    
    var loaded = false
    
    private var groupDictionary: Dictionary<Int, SpendCraft.Group>
    public var categoryDictionary: Dictionary<Int, SpendCraft.Category>
    
    static let shared: CategoriesStore = CategoriesStore()
    
    init() {
        self.groupDictionary = Dictionary()
        self.categoryDictionary = Dictionary()
        
        self.unassigned = SpendCraft.Category(id: -2, groupId: 0, name: "Unassigned", balance: 0, type: .unassigned, monthlyExpenses: false, hidden: false)
        self.fundingPool = SpendCraft.Category(id: -3, groupId: 0, name: "Funding Pool", balance: 0, type: .fundingPool, monthlyExpenses: false, hidden: false)
        self.accountTransfer = SpendCraft.Category(id: -4, groupId: 0, name: "Account Transfers", balance: 0, type: .accountTransfer, monthlyExpenses: false, hidden: false)
        
        self.noGroupId = -1
    }

    @MainActor
    func load() async {
        if let categoriesResponse: [SpendCraft.Response.CategoryTreeNode] = try? await Http.get(path: "/api/groups") {
            self.makeTree(tree: categoriesResponse)
            self.write()
        }
        
        self.loaded = true
    }
    
    func makeTree(tree: [SpendCraft.Response.CategoryTreeNode]) {
        self.tree = tree.map {
            SpendCraft.TreeNode(node: $0)
        };
        
        self.groupDictionary = Dictionary()
        self.categoryDictionary = Dictionary()
        
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
        
        // Find nogroup group
        let noGroupNode = self.tree.first(where: {
            switch($0) {
            case .group(let group):
                return group.type == GroupType.noGroup
            case .category:
                return false
            }
        })

        let noGroup = noGroupNode?.getGroup()
        
        // Move the categories in the No Group group to the top level of the tree
        // and then delete the No Group group.
        if let noGroup = noGroup {
            self.noGroupId = noGroup.id

            noGroup.categories.forEach { cat in
                self.tree.append(SpendCraft.TreeNode(cat))
            }
            
            // Remove the noGroup group from the tree
            self.tree.removeAll {
                switch $0 {
                case .group(let group):
                    return group.id == noGroup.id
                case .category:
                    return false
                }
            }
            
            // With the noGroup group removed and the noGroup categories
            // moved to the top level, resort the top level of the the tree
            self.tree.sort {
                let name0: String = $0.name
                let name1: String = $1.name
                
                return name0 < name1
            }
        }
        
        // Find the System group
        let system = self.tree.first(where: {
            switch($0) {
            case .group(let group):
                return group.type == GroupType.system
            case .category:
                return false
            }
        })
        
        if let system = system {
            // Find the unassigned category
            switch(system) {
            case .category:
                print("category")
            case .group(let group):
                let unassigned = group.categories.first(where: { category in
                    category.type == CategoryType.unassigned
                })
                
                if let unassigned = unassigned {
                    self.unassigned = unassigned
                }
                
                let fundingPool = group.categories.first(where: { category in
                    category.type == CategoryType.fundingPool
                })
                
                if let fundingPool = fundingPool {
                    self.fundingPool = fundingPool
                }
                
                let accountTransfer = group.categories.first(where: { category in
                    category.type == CategoryType.accountTransfer
                })
                
                if let accountTransfer = accountTransfer {
                    self.accountTransfer = accountTransfer
                    // todo: Change this name in the database instead of here.
                    self.accountTransfer.name = "Account Transfers"
                }
                
                //                self.tree.removeAll {
                //                    $0.id == system.id
                //                }
            }
        }
    }
    
    private func addNodeToRoot(node: SpendCraft.TreeNode) {
        // Add the category to the top level of the tree
        let index = self.tree.firstIndex { n in
            n.name > node.name
        }
        
        if let index = index {
            self.tree.insert(node, at: index)
        }
        else {
            self.tree.append(node)
        }
    }
    
    private func insertCategory(group: SpendCraft.Group, category: SpendCraft.Category) {
        let index = group.categories.firstIndex { cat in
            cat.name > category.name
        }
        
        if let index = index {
            group.categories.insert(category, at: index)
        }
        else {
            group.categories.append(category)
        }
    }
    
    private func removeCategoryFromGroup(category: SpendCraft.Category) {
        if category.groupId == self.noGroupId {
            // Find and remove the category from the top level of the tree
            let index = self.tree.firstIndex { node in
                switch node {
                case .category(let c):
                    return c.id == category.id
                case .group:
                    return false
                }
            }
            
            if let index = index {
                self.tree.remove(at: index)
            }
        } else {
            // Find the group and remove the category from it
            let group = self.getGroup(groupId: category.groupId)
            
            if let group = group {
                let index = group.categories.firstIndex {
                    $0.id == category.id
                }
                
                if let index = index {
                    group.categories.remove(at: index)
                }
            }
        }
    }
    
    private func addCategoryToGroup(category: SpendCraft.Category, groupId: Int) {
        if groupId == self.noGroupId {
            // Add the category to the top level of the tree
            addNodeToRoot(node: SpendCraft.TreeNode(category))
        }
        else {
            // Find the new group and add the category to it
            let newGroup = self.getGroup(groupId: groupId)
            
            if let newGroup = newGroup {
                self.insertCategory(group: newGroup, category: category)
            }
        }
        
        category.groupId = groupId
    }
    
    @MainActor
    public func addCategory(name: String, groupId: Int) async {
        struct Data: Encodable {
            var name: String
            var groupId: Int
            var monthlyExpenses: Bool = false
        }
        
        let cat = Data(name: name, groupId: groupId)
    
        if let category: SpendCraft.Category = try? await Http.post(path: "/api/groups/\(groupId)/categories", data: cat) {
            self.addCategoryToGroup(category: category, groupId: groupId)
            
            // Add the category to the dictionary
            self.categoryDictionary.updateValue(category, forKey: category.id)
        }
    }
    
    @MainActor
    public func updateCategory(category: SpendCraft.Category, name: String, groupId: Int, hidden: Bool) async {
        struct Data: Encodable {
            var name: String
            var monthlyExpenses: Bool
            var hidden: Bool
        }
        
        let cat = Data(name: name, monthlyExpenses: category.monthlyExpenses, hidden: hidden)
    
        if let response: SpendCraft.Response.CategoryUpdate = try? await Http.patch(path: "/api/groups/\(groupId)/categories/\(category.id)", data: cat) {

            category.name = response.name
            category.monthlyExpenses = response.monthlyExpenses
            category.hidden = response.hidden
            
            // If the category changed groups...
            if (category.groupId != groupId) {
                self.removeCategoryFromGroup(category: category)
                self.addCategoryToGroup(category: category, groupId: groupId)
            }
        }
    }

    @MainActor
    public func deleteCategory(category: SpendCraft.Category) async {
        try? await Http.delete(path: "/api/groups/\(category.groupId)/categories/\(category.id)")
        
        self.removeCategoryFromGroup(category: category)
        self.categoryDictionary.removeValue(forKey: category.id)
    }

    @MainActor
    public func addGroup(name: String) async {
        struct Data: Encodable {
            var name: String
        }
        
        let group = Data(name: name)
    
        if let groupResponse: SpendCraft.Response.Group = try? await Http.post(path: "/api/groups", data: group) {
            let group = SpendCraft.Group(groupResponse: groupResponse)

            self.addNodeToRoot(node: SpendCraft.TreeNode(group))
            
            // Add the group to the dictionary
            self.groupDictionary.updateValue(group, forKey: group.id)
        }
    }

    @MainActor
    public func updateGroup(group: SpendCraft.Group, name: String, hidden: Bool) async {
        struct Data: Encodable {
            var name: String
            var hidden: Bool
        }
        
        let grp = Data(name: name, hidden: hidden)
    
        if let response: SpendCraft.Response.GroupUpdate = try? await Http.patch(path: "/api/groups/\(group.id)", data: grp) {
            group.name = response.name
            group.hidden = response.hidden
        }
    }

    @MainActor
    public func deleteGroup(group: SpendCraft.Group) async {
        try? await Http.delete(path: "/api/groups/\(group.id)")
        
        let index = self.tree.firstIndex { node in
            switch node {
            case .category:
                return false
            case .group(let g):
                return g.id == group.id
            }
        }
        
        if let index = index {
            // Remove the group from the tree and the dictionary
            self.tree.remove(at: index)
            self.groupDictionary.removeValue(forKey: group.id)
        }
    }

    public func getGroup(groupId: Int) -> SpendCraft.Group? {
        return self.groupDictionary[groupId]
    }

    public func getCategory(categoryId: Int) -> SpendCraft.Category? {
        return self.categoryDictionary[categoryId]
    }
    
    public func getCategoryName(categoryId: Int) -> String {
        let category = self.categoryDictionary[categoryId]
        
        if let category = category {
            let group = self.groupDictionary[category.groupId]
            
            if let group = group {
                if (group.type == GroupType.noGroup) {
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
    
    public func groups() -> [SpendCraft.Group] {
        return tree.compactMap { n in
            switch n {
            case .group(let group):
                return group
            case .category:
                return nil
            }
        }
    }

    func write() {
        if let data = try? JSONEncoder().encode(self.tree) {
            do {
                let archiveURL = FileManager.sharedContainerURL()
                    .appendingPathComponent("categories.json")
                
                try data.write(to: archiveURL)
                WidgetCenter.shared.reloadTimelines(ofKind: "app.spendcraft")
            } catch {
                print("Error: Can't write categories")
            }
        }
    }
}

extension Data {
    func toString() -> String {
        self.map { String(format: "%c", $0) }.joined()
    }
}
