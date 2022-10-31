//
//  GroupView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/20/22.
//

import SwiftUI
import Framework

struct GroupView: View {
    @ObservedObject var group: SpendCraft.Group
    @State var isExpanded: Bool = true
    
    var body: some View {
        DisclosureGroup(group.name, isExpanded: $isExpanded) {
            ForEach($group.categories) { $category in
                if !category.hidden {
                    CategoryView(category: category)
                }
            }
        }
    }
}

struct GroupView_Previews: PreviewProvider {
    static let group = SpendCraft.Group(id: 0, name: "Test Group", type: .regular, hidden: false, categories: [])
    static let categoryDictionary = Dictionary<Int, Category>()

    static var previews: some View {
        GroupView(group: group)
    }
}
