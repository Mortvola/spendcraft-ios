//
//  CategoryView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/20/22.
//

import SwiftUI
import Framework

struct CategoryView: View {
    @ObservedObject var category: SpendCraft.Category

    var body: some View {
        NavigationLink(value: category) {
            HStack {
                Text(category.name)
                Spacer()
                SpendCraft.AmountView(amount: category.balance)
            }
        }
    }
}

struct CategoryView_Previews: PreviewProvider {
    static let category = SpendCraft.Category(id: 0, groupId: 0, name: "Test Category", balance: 100, type: .regular, monthlyExpenses: true)

    static var previews: some View {
        CategoryView(category: category)
    }
}
