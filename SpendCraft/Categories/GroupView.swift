//
//  GroupView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/20/22.
//

import SwiftUI

struct GroupView: View {
    @Binding var group: Group
    @State var isExpanded: Bool = true
    let categories: Categories
    
    var body: some View {
        DisclosureGroup(group.name, isExpanded: $isExpanded) {
            ForEach($group.categories) { $category in
                CategoryView(category: $category, categories: categories)
            }
        }
    }
}

struct GroupView_Previews: PreviewProvider {
    static let group = Group(id: 0, name: "Test Group", type: "REGULAR", categories: [])
    static let categoryDictionary = Dictionary<Int, Category>()
    static let categories = Categories(tree: [])

    static var previews: some View {
        GroupView(group: .constant(group), categories: categories)
    }
}
