//
//  Categories.swift
//  Framework
//
//  Created by Richard Shields on 10/9/22.
//

import Foundation

public enum GroupType: String, Codable {
    case regular = "REGULAR"
    case noGroup = "NO GROUP"
    case system = "SYSTEM"
    case unknown = "UNKNOWN"
}


public enum CategoryType: String, Codable {
    case fundingPool = "FUNDING POOL"
    case regular = "REGULAR"
    case unassigned = "UNASSIGNED"
    case accountTransfer = "ACCOUNT TRANSFER"
    case unknown = "UNKNOWN"
}

public enum SpendCraft {
    public class Category: ObservableObject, Identifiable, Hashable, Codable {
        public var id: Int
        public var groupId: Int
        @Published public var name: String
        @Published public var balance: Double
        public var type: CategoryType
        public var monthlyExpenses: Bool
        public var group: Group?
        
        public static func == (lhs: Category, rhs: Category) -> Bool {
            lhs === rhs
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        public init(id: Int, groupId: Int, name: String, balance: Double, type: CategoryType, monthlyExpenses: Bool) {
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
        
        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            id = try container.decode(Int.self, forKey: .id)
            groupId = try container.decode(Int.self, forKey: .groupId)
            name = try container.decode(String.self, forKey: .name)
            balance = try container.decode(Double.self, forKey: .balance)
            type = try container.decode(CategoryType.self, forKey: .type)
            monthlyExpenses = try container.decode(Bool.self, forKey: .monthlyExpenses)
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(groupId, forKey: .groupId)
            try container.encode(name, forKey: .name)
            try container.encode(Decimal(balance), forKey: .balance)
            try container.encode(type, forKey: .type)
            try container.encode(monthlyExpenses, forKey: .monthlyExpenses)
        }
    }
    
    public class Group: ObservableObject, Identifiable, Codable {
        public var id: Int
        @Published public var name: String
        public var type: GroupType
        @Published public var categories: [SpendCraft.Category]
        
        public init(id: Int, name: String, type: GroupType, categories: [SpendCraft.Category]) {
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
       
        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            id = try container.decode(Int.self, forKey: .id)
            name = try container.decode(String.self, forKey: .name)
            type = try container.decode(GroupType.self, forKey: .type)
            categories = try container.decode([SpendCraft.Category].self, forKey: .categories)
            
            categories.forEach { category in
                category.group = self
            }
        }
       
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encode(id, forKey: .id)
            try container.encode(name, forKey: .name)
            try container.encode(type, forKey: .type)
            try container.encode(categories, forKey: .categories)
        }
    }
    
    public enum TreeNode: Identifiable, Codable {
        case group(SpendCraft.Group)
        case category(SpendCraft.Category)
        
        public init(node: SpendCraft.Response.CategoryTreeNode) {
            switch(node) {
            case .category(let category):
                self = .category(SpendCraft.Category(id: category.id, groupId: category.groupId, name: category.name, balance: category.balance, type: category.type, monthlyExpenses: category.monthlyExpenses))
            case .group(let group):
                let cats = group.categories.map {
                    SpendCraft.Category(id: $0.id, groupId: $0.groupId, name: $0.name, balance: $0.balance, type: $0.type, monthlyExpenses: $0.monthlyExpenses)
                }
                self = .group(SpendCraft.Group(id: group.id, name: group.name, type: group.type, categories: cats))
            }
        }
        
        public init(_ group: Group) {
            self = .group(group)
        }
        
        public init(_ category: Category) {
            self = .category(category)
        }
        
        public var id: String {
            switch self {
            case .category(let category):
                return String("Cat-\(category.id)")
            case .group(let group):
                return String("Grp-\(group.id)")
            }
        }
        
        public var name: String {
            switch self {
            case .category(let category):
                return category.name
            case .group(let group):
                return group.name
            }
        }
        
        public var children: [TreeNode]? {
            switch self {
            case .category:
                return nil
            case .group(let group):
                return group.categories.map{
                    TreeNode.category($0)
                }
            }
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            
            let category = try? container.decode(SpendCraft.Category.self)
            if let category = category {
                self = .category(category)
                return
            }
            
            let group = try? container.decode(SpendCraft.Group.self)
            if let group = group {
                self = .group(group)
                return
            }
            
            throw MyError.runtimeError("Failed to decode tree node")
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            
            switch self {
            case .category(let category):
                try container.encode(category)
            case .group(let group):
                try container.encode(group)
            }
        }
    }
    
    public class CategoryTree {
        public var tree: [TreeNode]
        private var groupDictionary: Dictionary<Int, SpendCraft.Group>
        private var categoryDictionary: Dictionary<Int, SpendCraft.Category>
        
        public init(_ tree: [TreeNode] = []) {
            self.tree = tree
            self.groupDictionary = Dictionary()
            self.categoryDictionary = Dictionary()
            
            buildDictionaries()
        }
        
        public func read() {
            let archiveURL =
            FileManager.sharedContainerURL()
                .appendingPathComponent("categories.json")
            
            if let data = try? Data(contentsOf: archiveURL) {
                do {
                    self.tree = try JSONDecoder().decode([SpendCraft.TreeNode].self, from: data)
                    buildDictionaries()
                } catch {
                    print("Error: Can't decode contents of categories.json \(error)")
                }
            }
        }
        
        private func buildDictionaries() {
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
                        category.group = group
                    }
                    break
                }
            }
        }
        
        public func getCategory(categoryId: Int) -> SpendCraft.Category? {
            return self.categoryDictionary[categoryId]
        }
    }
    
    public static func readWatchList() -> [Int] {
        let watchedFile = "watched.json"
        let archiveURL =
            FileManager.sharedContainerURL()
              .appendingPathComponent(watchedFile)

        if let data = try? Data(contentsOf: archiveURL) {
            do {
                let catIds = try JSONDecoder().decode([Int].self, from: data)
                
                return catIds;
            } catch {
                print("Error: Can't decode contents of \(watchedFile): \(error)")
            }
        }
        
        return []
    }
}

extension FileManager {
  static func sharedContainerURL() -> URL {
    return FileManager.default.containerURL(
      forSecurityApplicationGroupIdentifier: "group.app.spendcraft"
    )!
  }
}
