//
//  CategoryList.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/22/22.
//

import SwiftUI

struct CategoryList: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var categoriesStore = CategoriesStore.shared
    @Binding var selection: Int?
    
    var body: some View {
        List(categoriesStore.tree) { node in
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
                ForEach(group.categories) { category in
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
    static let selection = 0
    
    static var previews: some View {
        CategoryList(selection: .constant(selection))
    }
}
