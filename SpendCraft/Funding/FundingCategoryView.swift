//
//  FundingCategoryView.swift
//  SpendCraft
//
//  Created by Richard Shields on 10/26/22.
//

import SwiftUI
import Framework

struct FundingCategoryView: View {
    @ObservedObject var category: SpendCraft.Category
    @Binding var value: Double?
    @Binding var allowed: Double?
    
    init(category: SpendCraft.Category, trxData: Binding<Transaction.Data>) {
        self.category = category

        let trxCat = trxData.categories.first {
            $0.categoryId.wrappedValue == category.id
        }

        if let trxCat = trxCat {
            _value = trxCat.amount
        }
        else {
            _value = .constant(0.0)
        }
        
        let trxAllowed = trxData.allowedToSpend.first {
            $0.categoryId.wrappedValue == category.id
        }
        
        if let trxAllowed = trxAllowed {
            _allowed = trxAllowed.amount
        }
        else {
            _allowed = .constant(0.0)
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(category.name)
                Spacer()
            }
            .padding(.bottom, 2)
            HStack {
                Spacer()
                VStack {
                    HStack() {
                        Text("Current")
                        Spacer()
                        SpendCraft.AmountView(amount: category.balance)
                            .frame(maxWidth: 100, alignment: .trailing)
                    }
                    Spacer()
                    HStack {
                        Text("Funding")
                        Spacer()
                        NumericField(value: $value)
                            .frame(maxWidth: 100, alignment: .trailing)
                            .border(edge: .bottom)
                    }
                    Spacer()
                    HStack{
                        Text("Balance")
                        Spacer()
                        SpendCraft.AmountView(amount: category.balance + (value ?? 0))
                            .frame(maxWidth: 100, alignment: .trailing)
                    }
                    Spacer()
                    HStack {
                        Text("Expected to Spend")
                        Spacer()
                        NumericField(value: $allowed)
                            .frame(maxWidth: 100, alignment: .trailing)
                    }
                    .padding(.top)
                }
                .frame(maxWidth: 245)
            }
        }
    }
}

//struct FundingCategoryView_Previews: PreviewProvider {
//    static let categories = [
//        SpendCraft.Category(id: 0, groupId: 0, name: "Test Category 1", balance: 100, type: .regular, monthlyExpenses: true),
//        SpendCraft.Category(id: 0, groupId: 0, name: "Test Category 2", balance: 200, type: .regular, monthlyExpenses: true)
//    ]
//    static let isExpanded = true
//
//    static var previews: some View {
//        Form {
//            DisclosureGroup("Test Group", isExpanded: .constant(isExpanded)) {
//                ForEach(categories) { category in
//                    FundingCategoryView(category: category, trxData: .constant(SampleData.transactions[0].data))
//                }
//            }
//        }
//    }
//}
