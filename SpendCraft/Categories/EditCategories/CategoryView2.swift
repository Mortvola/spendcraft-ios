//
//  CategoryView2.swift
//  SpendCraft
//
//  Created by Richard Shields on 10/12/22.
//

import SwiftUI
import Framework

struct CategoryView2: View {
    @ObservedObject var category: SpendCraft.Category
    @State var isEditing = false
    
    var body: some View {
        Button(action: {
            isEditing = true
        }) {
            Text(category.name)
        }
        .sheet(isPresented: $isEditing) {
            EditCategoryView(category: category, isOpen: $isEditing)
                .presentationDetents([.medium])
        }
    }
}

struct CategoryView2_Previews: PreviewProvider {
    static let category = SpendCraft.Category(id: 0, groupId: 0, name: "Test", balance: 100.0, type: .regular, monthlyExpenses: true)

    static var previews: some View {
        CategoryView2(category: category)
    }
}
