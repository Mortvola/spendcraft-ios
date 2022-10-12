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
    private var categoryDictionary: Dictionary<Int, SpendCraft.Category>
    
    static let shared: CategoriesStore = CategoriesStore()
    
    init() {
        self.groupDictionary = Dictionary()
        self.categoryDictionary = Dictionary()
        
        self.unassigned = SpendCraft.Category(id: -2, groupId: 0, name: "Unassigned", balance: 0, type: .unassigned, monthlyExpenses: false)
        self.fundingPool = SpendCraft.Category(id: -3, groupId: 0, name: "Funding Pool", balance: 0, type: .fundingPool, monthlyExpenses: false)
        self.accountTransfer = SpendCraft.Category(id: -4, groupId: 0, name: "Account Transfer", balance: 0, type: .accountTransfer, monthlyExpenses: false)
        
        self.noGroupId = -1
    }
    
    func load() {
        try? Http.get(path: "/api/groups") { data in
            guard let data = data else {
                print ("data is nil")
                return;
            }
            
            var categoriesResponse: [SpendCraft.Response.CategoryTreeNode]
            do {
                categoriesResponse = try JSONDecoder().decode([SpendCraft.Response.CategoryTreeNode].self, from: data)
            }
            catch {
                print ("Error: \(error)")
                return
            }
            
            DispatchQueue.main.async {
                self.makeTree(tree: categoriesResponse)
                self.write()
                self.loaded = true
            }
        }
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
                }
                
                //                self.tree.removeAll {
                //                    $0.id == system.id
                //                }
            }
        }
    }
    
    public func addCategory(name: String, groupId: Int) {
        struct Data: Encodable {
            var name: String
            var groupId: Int
            var monthlyExpenses: Bool = false
        }
        
        let cat = Data(name: name, groupId: groupId)
    
        try? Http.post(path: "/api/groups/\(groupId)/categories", data: cat) { data in
            guard let data = data else {
                return
            }
            
            let category: SpendCraft.Category
            do {
                category = try JSONDecoder().decode(SpendCraft.Category.self, from: data)
            }
            catch {
                print ("Error: \(error)")
                return
            }
    
            DispatchQueue.main.async {
                if (groupId == self.noGroupId) {
                    let index = self.tree.firstIndex { node in
                        node.name > category.name
                    }
                    
                    if let index = index {
                        self.tree.insert(SpendCraft.TreeNode(category), at: index)
                    }
                    else {
                        self.tree.append(SpendCraft.TreeNode(category))
                    }
                }
                else {
                    // Find the group to which to add the new category
                    let group = self.tree.first { node in
                        switch node {
                        case .category:
                            return false
                        case .group(let g):
                            return g.id == groupId
                        }
                    }
                    
                    if let group = group?.getGroup() {
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
                }
                
                // Add the category to the dictionary
                self.categoryDictionary.updateValue(category, forKey: category.id)
            }
        }
    }

    public func addGroup(name: String) {
        struct Data: Encodable {
            var name: String
        }
        
        let group = Data(name: name)
    
        try? Http.post(path: "/api/groups", data: group) { data in
            guard let data = data else {
                return
            }
            
            let groupResponse: SpendCraft.Response.Group
            do {
                groupResponse = try JSONDecoder().decode(SpendCraft.Response.Group.self, from: data)
            }
            catch {
                print ("Error: \(error)")
                return
            }
    
            DispatchQueue.main.async {
                let group = SpendCraft.Group(groupResponse: groupResponse)
                
                let index = self.tree.firstIndex { node in
                    node.name > group.name
                }
                
                if let index = index {
                    self.tree.insert(SpendCraft.TreeNode(group), at: index)
                }
                else {
                    self.tree.append(SpendCraft.TreeNode(group))
                }
                
                // Add the group to the dictionary
                self.groupDictionary.updateValue(group, forKey: group.id)
            }
        }
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
