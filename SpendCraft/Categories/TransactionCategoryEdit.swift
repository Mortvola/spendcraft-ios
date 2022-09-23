//
//  TransactionCategoryView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/20/22.
//

import SwiftUI

struct TransactionCategoryEdit: View {
    @Binding var transactionCategory: Transaction.Category
    let categories: Categories

    var body: some View {
        VStack(alignment: .leading) {
            HStack() {
                CategoryPicker(selection: $transactionCategory.categoryId, categories: categories)
                Spacer()
                NumericField(value: $transactionCategory.amount)
                    .frame(maxWidth: 100)
            }
            TextField("Comment", text: $transactionCategory.comment)
                .truncationMode(.tail)
        }
    }
}

struct TransactionCategoryView_Previews: PreviewProvider {
    static let categories = Categories(tree: [])

    static var previews: some View {
        TransactionCategoryEdit(transactionCategory: .constant( Transaction.sampleData[0].categories[0]), categories: categories)
    }
}
