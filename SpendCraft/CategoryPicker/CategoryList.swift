//
//  CategoryList.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/22/22.
//

import SwiftUI

struct CategoryList: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let categories: Categories
    @Binding var selection: Int?
    
    var body: some View {
        List(.constant(categories.tree)) { $node in
            switch (node) {
            case .category(let category):
                Button(action: {
                    selection = category.id
                    self.presentationMode.wrappedValue.dismiss()
                } ) {
                    Text(category.name)
                        .tag(category.id)
                }
            case .group(let group):
                Text(group.name)
                ForEach(.constant(group.categories)) { $category in
                    Button(action: {
                        selection = category.id
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Text(category.name)
                            .tag(category.id)
                    }
                    .padding(.leading)
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Select Category")
    }
}

struct CategoryList_Previews: PreviewProvider {
    static let categories = Categories(tree: [])
    static let selection = 0
    
    static var previews: some View {
        CategoryList(categories: categories, selection: .constant(selection))
    }
}
