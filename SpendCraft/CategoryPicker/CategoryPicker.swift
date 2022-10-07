//
//  CategoryPicker.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/22/22.
//

import SwiftUI

struct CategoryPicker: View {
    @Binding var selection: Int?
    var categoriesStore = CategoriesStore.shared

    func categoryText(selection: Int?) -> String {
        guard let selection = selection else {
            return "Category"
        }
        
        return categoriesStore.getCategoryName(categoryId: selection);
    }

    var body: some View {
        NavigationLink(destination: CategoryList(selection: $selection)) {
            Text(categoryText(selection: selection))
                .truncationMode(.tail)
                .foregroundColor(selection == nil ? Color(uiColor: .placeholderText) : nil)
        }
    }
}

struct CategoryPicker_Previews: PreviewProvider {
    static let selection = 0

    static var previews: some View {
        CategoryPicker(selection: .constant(selection))
    }
}
