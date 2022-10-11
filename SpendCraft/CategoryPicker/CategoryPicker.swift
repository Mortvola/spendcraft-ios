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

    var categoryText: String {
        guard let selection = selection else {
            return "Add Category"
        }
        
        return categoriesStore.getCategoryName(categoryId: selection);
    }
    
    var color: Color? {
        if selection != nil {
            return nil
        }
        
        return Color(uiColor: .link)
    }

    var body: some View {
        NavigationLink(destination: CategoryList(selection: $selection)) {
            HStack {
                Text(categoryText)
                    .truncationMode(.tail)
                    .foregroundColor(color)
                Spacer()
            }
        }
    }
}

struct CategoryPicker_Previews: PreviewProvider {
    static let selection = 0

    static var previews: some View {
        CategoryPicker(selection: .constant(selection))
    }
}
