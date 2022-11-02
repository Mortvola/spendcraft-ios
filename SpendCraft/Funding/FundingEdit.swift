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
    @State var trxData = Transaction.Data()
    var categoriesStore = CategoriesStore.shared
    @State var showPopover: Int? = nil
    
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
                            if !category.hidden {
                                FundingCategoryView(category: category, trxData: $trxData, showPopover: $showPopover)
                            }
                        case .group(let group):
                            if (!group.hidden && group.type != GroupType.system) {
                                FundingGroupView(group: group, trxData: $trxData, showPopover: $showPopover)
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
                        Task {
                            transaction.update(from: trxData)
                            await transaction.saveCategoryTransfer()
                            isOpen = false;
                        }
                    }
                }
            }
            .task {
                trxData = await transaction.data()
            }
            .simultaneousGesture(
                TapGesture()
                    .onEnded {
                        print("Parent tapped")
                        showPopover = nil
                    }
            )
        }
    }
}

//struct FundingEdit_Previews: PreviewProvider {
//    static var previews: some View {
//        FundingEdit(transaction: SampleData.transactions[0], isOpen: .constant(true), trxData: .constant(SampleData.transactions[0].data))
//    }
//}
