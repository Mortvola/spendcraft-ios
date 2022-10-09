//
//  CategoriesStore.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/19/22.
//

import Foundation
import Combine
import SpendCraftFramework

import Foundation

extension FileManager {
  static func sharedContainerURL() -> URL {
    return FileManager.default.containerURL(
      forSecurityApplicationGroupIdentifier: "group.app.spendcraft"
    )!
  }
}

enum GroupType: String, Codable {
    case regular = "REGULAR"
    case noGroup = "NO GROUP"
    case system = "SYSTEM"
    case unknown = "UNKNOWN"
}


enum CategoryType: String, Codable {
    case fundingPool = "FUNDING POOL"
    case regular = "REGULAR"
    case unassigned = "UNASSIGNED"
    case accountTransfer = "ACCOUNT TRANSFER"
    case unknown = "UNKNOWN"
}

final class CategoriesStore: ObservableObject {
    class Category: ObservableObject, Identifiable, Hashable, Codable {
        var id: Int
        var groupId: Int
        @Published var name: String
        @Published var balance: Double
        var type: CategoryType
        var monthlyExpenses: Bool
        
        static func == (lhs: Category, rhs: Category) -> Bool {
            lhs === rhs
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        init(id: Int, groupId: Int, name: String, balance: Double, type: CategoryType, monthlyExpenses: Bool) {
            self.id = id
            self.groupId = groupId
            self.name = name
            self.balance = balance
            self.type = type
            self.monthlyExpenses = monthlyExpenses
        }
        
        enum CodingKeys: String, CodingKey {
            case id
            case groupId
            case name
            case balance
            case type
            case monthlyExpenses
        }

        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            id = try container.decode(Int.self, forKey: .id)
            groupId = try container.decode(Int.self, forKey: .groupId)
            name = try container.decode(String.self, forKey: .name)
            balance = try container.decode(Double.self, forKey: .balance)
            type = try container.decode(CategoryType.self, forKey: .type)
            monthlyExpenses = try container.decode(Bool.self, forKey: .type)
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(groupId, forKey: .groupId)
            try container.encode(name, forKey: .name)
            try container.encode(Decimal(balance), forKey: .balance)
            try container.encode(type, forKey: .type)
            try container.encode(monthlyExpenses, forKey: .monthlyExpenses)
        }
    }
    
    class Group: ObservableObject, Identifiable, Codable {
        var id: Int
        @Published var name: String
        var type: GroupType
        @Published var categories: [Category]
        
        init(id: Int, name: String, type: GroupType, categories: [Category]) {
            self.id = id
            self.name = name
            self.type = type
            self.categories = categories
        }

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case type
            case categories
        }

        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            id = try container.decode(Int.self, forKey: .id)
            name = try container.decode(String.self, forKey: .name)
            type = try container.decode(GroupType.self, forKey: .type)
            categories = try container.decode([Category].self, forKey: .categories)
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encode(id, forKey: .id)
            try container.encode(name, forKey: .name)
            try container.encode(type, forKey: .type)
            try container.encode(categories, forKey: .categories)
        }
    }
    
    enum TreeNode: Identifiable, Codable {
        case group(Group)
        case category(Category)
        
        init(node: Response.CategoryTreeNode) {
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

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            
            switch self {
            case .category(let category):
                try container.encode(category)
            case .group(let group):
                try container.encode(group)
            }
        }
    }
    
    @Published var tree: [TreeNode] = []
    @Published var unassigned: Category
    @Published var fundingPool: Category
    @Published var accountTransfer: Category
    
    var loaded = false
    
    private var groupDictionary: Dictionary<Int, Group>
    private var categoryDictionary: Dictionary<Int, Category>
    
    static let shared: CategoriesStore = CategoriesStore()
    
    init() {
        self.groupDictionary = Dictionary()
        self.categoryDictionary = Dictionary()
        
        self.unassigned = Category(id: -2, groupId: 0, name: "Unassigned", balance: 0, type: .unassigned, monthlyExpenses: false)
        self.fundingPool = Category(id: -3, groupId: 0, name: "Funding Pool", balance: 0, type: .fundingPool, monthlyExpenses: false)
        self.accountTransfer = Category(id: -4, groupId: 0, name: "Account Transfer", balance: 0, type: .accountTransfer, monthlyExpenses: false)
    }
    
    func load() {
        try? Http.get(path: "/api/groups") { data in
            guard let data = data else {
                print ("data is nil")
                return;
            }
            
            var categoriesResponse: [Response.CategoryTreeNode]
            do {
                categoriesResponse = try JSONDecoder().decode([Response.CategoryTreeNode].self, from: data)
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
    
    func makeTree(tree: [Response.CategoryTreeNode]) {
        self.tree = tree.map {
            CategoriesStore.TreeNode(node: $0)
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
        let noGroup = self.tree.first(where: {
            switch($0) {
            case .group(let group):
                return group.type == GroupType.noGroup
            case .category:
                return false
            }
        })
        
        // Move the categories in the No Group group to the top level of the tree
        // and then delete the No Group group.
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
    
    public func getCategory(categoryId: Int) -> Category? {
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
    
    func write() {
        if let data = try? JSONEncoder().encode(self.tree) {
            print(data.toString())
            do {
                let archiveURL = FileManager.sharedContainerURL()
                    .appendingPathComponent("categories.json")
                
                try data.write(to: archiveURL)
                print(archiveURL)
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
