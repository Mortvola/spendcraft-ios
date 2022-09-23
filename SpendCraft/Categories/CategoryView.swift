//
//  CategoryView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/20/22.
//

import SwiftUI

struct CategoryView: View {
    @Binding var category: Category
    let categories: Categories
    
    var body: some View {
        NavigationLink(destination: RegisterView(category: $category, categories: categories)) {
            HStack {
                Text(category.name)
                Spacer()
                AmountView(amount: category.balance)
            }
        }
    }
}

struct CategoryView_Previews: PreviewProvider {
    static let category = Category(id: 0, groupId: 0, name: "Test Category", balance: 100, type: "REGULAR", monthlyExpenses: true)
    static let categories = Categories(tree: [])

    static var previews: some View {
        CategoryView(category: .constant(category), categories: categories)
    }
}
