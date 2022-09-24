//
//  TransactionDetailView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/18/22.
//

import SwiftUI

struct TransactionEdit: View {
    @Binding var transaction: Transaction.Data
    let categories: Categories
    static var next: Int = 0

    static func nextId() -> Int {
        next -= 1
        
        return next
    }

    var body: some View {
        Form {
            List {
                Section {
                    HStack {
                        Text("Date")
                        Spacer()
                        Text(formatDate(date: transaction.date))
                    }
                    HStack {
                        Text("Name")
                        Spacer()
                        Text(transaction.name)
                    }
                    HStack {
                        Text("Amount")
                        Spacer()
                        AmountView(amount: transaction.amount)
                    }
                    HStack {
                        Text("Institution")
                        Spacer()
                        Text(transaction.institution)
                    }
                    HStack {
                        Text("Account")
                        Spacer()
                        Text(transaction.account)
                    }
                }

                Section(header: Text("Categories")) {
                    ForEach($transaction.categories) { $trxCat in
                        TransactionCategoryEdit(transactionCategory: $trxCat, categories: categories)
                    }
                    .onDelete { indices in
                        transaction.categories.remove(atOffsets: indices)
                    }
                    
                    Button(action: {
                        var category = Transaction.Category();
                        category.id = TransactionEdit.nextId()
                        transaction.categories.append(category)
                    }) {
                        Text("Add Category")
                            .foregroundColor(Color.accentColor)
                    }
                }
            }
        }
    }
}

struct TransactionEdit_Previews: PreviewProvider {
    static let categoryDictionary = Dictionary<Int, Category>()
    static let categories = Categories(tree: [])
    
    static var previews: some View {
        TransactionEdit(transaction: .constant(Transaction.sampleData[0].data), categories: categories)
            .previewInterfaceOrientation(.portraitUpsideDown)
    }
}
