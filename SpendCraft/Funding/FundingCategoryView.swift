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
    var adjusted: Bool
    var adjustedText: String
    @Binding var showPopover: Int?
    
    init(category: SpendCraft.Category, trxData: Binding<Transaction.Data>, showPopover: Binding<Int?>) {
        self.category = category
        self.adjusted = false
        self.adjustedText = ""
        self._showPopover = showPopover
        
        let trxCat = trxData.categories.first {
            $0.categoryId.wrappedValue == category.id
        }

        if let trxCat = trxCat {
            _value = trxCat.amount
            self.adjusted = trxCat.adjusted.wrappedValue
            self.adjustedText = trxCat.adjustedText.wrappedValue
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
        ZStack {
            if adjusted {
                HStack {
                    Image(systemName: "exclamationmark.shield")
                        .foregroundColor(.red)
                        .highPriorityGesture (
                            TapGesture()
                                .onEnded {
                                    print("Button tap gesture")
                                    showPopover = category.id
                                }
                        )
                    Spacer()
                }
            }
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
            if showPopover == category.id {
                Text(adjustedText)
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                    .background(.white)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(.gray, lineWidth: 1))
                    .onTapGesture {
                        print("popover tapped")
                        showPopover = nil
                    }
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
