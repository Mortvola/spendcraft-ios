//
//  CategoryPicker.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/22/22.
//

import SwiftUI

struct CategoryPicker: View {
    @Binding var selection: Int?
    let categories: Categories

    func categoryText(selection: Int?) -> String {
        guard let selection = selection else {
            return "Category"
        }
        
        return categories.getCategoryName(categoryId: selection);
    }

    var body: some View {
        NavigationLink(destination: CategoryList(categories: categories, selection: $selection)) {
            Text(categoryText(selection: selection))
                .truncationMode(.tail)
                .foregroundColor(selection == nil ? Color(uiColor: .placeholderText) : nil)
        }
    }
}

struct CategoryPicker_Previews: PreviewProvider {
    static let selection = 0
    static let categories = Categories(tree: [])

    static var previews: some View {
        CategoryPicker(selection: .constant(selection), categories: categories)
    }
}
