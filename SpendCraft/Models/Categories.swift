//
//  Categories.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/19/22.
//

import Foundation

struct Categories {
    var tree: [CategoryTreeNode] = []
    var groupDictionary: Dictionary<Int, Group>
    var categoryDictionary: Dictionary<Int, Category>
    
    init(tree: [CategoryTreeNode]) {
        self.tree = tree;
        self.groupDictionary = Dictionary()
        self.categoryDictionary = Dictionary()

        // Find nogroup group
        let group = self.tree.first(where: {
            switch($0) {
            case .group(let group):
                return group.type == "NO GROUP"
            case .category:
                return false
            }
        })
        
        if let group = group {
            group.children?.forEach { node in
                self.tree.append(node)
            }
            
            self.tree.removeAll {
                $0.id == group.id
            }

            self.tree.sort {
                let name0: String = $0.name
                let name1: String = $1.name

                return name0 < name1
            }
        }

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
}
