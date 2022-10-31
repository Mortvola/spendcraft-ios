//
//  CategoryList.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/22/22.
//

import SwiftUI

struct CategoryList: View {
    var categoriesStore = CategoriesStore.shared
    @Binding var selection: Int?
    
    var body: some View {
        List(categoriesStore.tree) { node in
            switch (node) {
            case .category(let category):
                if !category.hidden {
                    CategoryItem(selection: $selection, category: category)
                }
            case .group(let group):
                if !group.hidden {
                    Text(group.name)
                    ForEach(group.categories) { category in
                        if !category.hidden {
                            CategoryItem(selection: $selection, category: category)
                                .padding(.leading)
                        }
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Select Category")
    }
}

struct CategoryList_Previews: PreviewProvider {
    static let selection = 0
    
    static var previews: some View {
        CategoryList(selection: .constant(selection))
    }
}
