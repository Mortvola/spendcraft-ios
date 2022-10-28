//
//  FundingView.swift
//  SpendCraft
//
//  Created by Richard Shields on 10/26/22.
//

import SwiftUI
import Framework

struct FundingEdit: View {
    @ObservedObject var transaction: Transaction
    @Binding var isOpen: Bool
    @Binding var trxData: Transaction.Data
    var categoriesStore = CategoriesStore.shared

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Form {
                    Section {
                        Text("Date")
                    }
                    ForEach(categoriesStore.tree) { node in
                        switch node {
                        case .category(let category):
                            FundingCategoryView(category: category, trxData: $trxData)
                        case .group(let group):
                            if (group.type != GroupType.system) {
                                FundingGroupView(group: group, trxData: $trxData)
                            }
                        }
                    }
                }
                VStack {
                    LabeledContent("Funding Pool") {
                        SpendCraft.AmountView(amount: categoriesStore.fundingPool.balance)
                    }
                    LabeledContent("Funding Total") {
                        SpendCraft.AmountView(amount: trxData.fundingTotal)
                    }
                    LabeledContent("Funding Pool Balance") {
                        SpendCraft.AmountView(amount: categoriesStore.fundingPool.balance - trxData.fundingTotal)
                    }
                    LabeledContent("Expected Total") {
                        SpendCraft.AmountView(amount: trxData.allowedTotal)
                    }
                    .padding(.top)
                }
                .padding()
                .border(edge: .top)
            }
            .navigationTitle("Category Funding")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isOpen = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        isOpen = false;
                    }
                }
            }
        }
    }
}

//struct FundingEdit_Previews: PreviewProvider {
//    static var previews: some View {
//        FundingEdit(transaction: SampleData.transactions[0], isOpen: .constant(true), trxData: .constant(SampleData.transactions[0].data))
//    }
//}
