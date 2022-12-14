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
    @Binding var trxData: FundingTransaction.Data
    var adjusted: Bool
    var adjustedText: String
    @Binding var showPopover: Int?
    
    func current() -> Double {
        guard let transaction = trxData.transaction else {
            return category.balance
        }
        
        if (transaction.id < 0) {
            return category.balance
        }

        let trxCat2 = trxData.transaction?.categories.first {
            $0.categoryId == category.id
        }
        
        return category.balance - (trxCat2?.amount ?? 0)
    }

    var body: some View {
        if !category.hidden {
            if let trxCatIndex = trxData.trxCategoryIndex(categoryId: category.id) {
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
                        VStack {
                            HStack {
                                TitledAmountView(title: "Current", amount: current())
                                Spacer()
                                VStack {
                                    HStack {
                                        Spacer()
                                        Text("Funding")
                                    }
                                    .padding(.bottom, 2)
                                    HStack {
                                        Spacer()
                                        NumericField(value: $trxData.categories[trxCatIndex].amount)
                                        .border(edge: .bottom)
                                    }
                                }
                                Spacer()
                                TitledAmountView(title: "Balance", amount: current() + (trxData.categories[trxCatIndex].amount ?? 0))
                            }
                            HStack {
                                Spacer()
                                Text("Expected to Spend")
                                NumericField(value: $trxData.categories[trxCatIndex].allowed)
                                    .frame(maxWidth: 100, alignment: .trailing)
                                    .border(edge: .bottom)
                            }
                            .padding(.top)
                        }
                    }
                    .padding([.top, .bottom], 16)
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
    }
}

struct FundingCategoryView_Previews: PreviewProvider {
    static let categories = [
        SpendCraft.Category(id: 0, groupId: 0, name: "Test Category 1", balance: 100, type: .regular, monthlyExpenses: true, hidden: false),
        SpendCraft.Category(id: 1, groupId: 0, name: "Test Category 2", balance: 200, type: .regular, monthlyExpenses: true, hidden: false)
    ]
    static let trxData = FundingTransaction.Data(date: Date.now, categories: [FundingTransaction.Category(id: 0, categoryId: 0, amount: 20.0, comment: "")])

    static let isExpanded = true

    static var previews: some View {
        Form {
            DisclosureGroup("Test Group", isExpanded: .constant(isExpanded)) {
                ForEach(categories) { category in
                    FundingCategoryView(category: category, trxData: .constant(trxData), adjusted: false, adjustedText: "", showPopover: .constant(-1))
                }
            }
        }
    }
}
