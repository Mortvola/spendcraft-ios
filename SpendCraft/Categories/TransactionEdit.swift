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
                        print("delete transaction category at \(indices)")
                    }
                    
                    Button(action: {
                        transaction.categories.append(Transaction.Category())
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
