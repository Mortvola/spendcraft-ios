//
//  FundingView.swift
//  SpendCraft
//
//  Created by Richard Shields on 10/26/22.
//

import SwiftUI
import Framework

struct FundingEdit: View {
    @ObservedObject var transaction: FundingTransaction
    @Binding var isOpen: Bool
    @State var trxData = FundingTransaction.Data()
    var categoriesStore = CategoriesStore.shared
    @State var showPopover: Int? = nil
    @State var initialized = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if initialized {
                    Form {
                        Section {
                            LabeledContent("Date") {
                                Text(formatDate(date: trxData.date))
                            }
                        }
                        FundingTree(trxData: $trxData, showPopover: $showPopover)
                    }
                    FundingEditFooter(trxData: $trxData)
                }
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
                            await transaction.save()
                            isOpen = false;
                        }
                    }
                }
            }
            .task() {
                if !initialized {
                    let data = await transaction.data()
                    trxData.update(from: data)
                    initialized = true
                }
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
