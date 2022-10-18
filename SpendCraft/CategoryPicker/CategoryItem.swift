//
//  CategoryItem.swift
//  SpendCraft
//
//  Created by Richard Shields on 10/11/22.
//

import SwiftUI
import Framework

struct CategoryItem: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Binding var selection: Int?
    let category: SpendCraft.Category

    var body: some View {
        Button(action: {
            selection = category.id
            self.presentationMode.wrappedValue.dismiss()
        } ) {
            HStack {
                Text(category.name)
                    .tag(category.id)
                Spacer()
                SpendCraft.AmountView(amount: category.balance)
            }
        }
    }
}

struct CategoryItem_Previews: PreviewProvider {
    static var previews: some View {
        let category = SpendCraft.Category(id: 0, groupId: 0, name: "Test", balance: 100.0, type: .regular, monthlyExpenses: true)
    
        CategoryItem(selection: .constant(nil), category: category)
    }
}
