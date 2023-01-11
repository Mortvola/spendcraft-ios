//
//  FundingTransactionView.swift
//  SpendCraft
//
//  Created by Richard Shields on 11/4/22.
//

import SwiftUI
import Framework

struct FundingTransactionView: View {
    @ObservedObject var trx: FundingTransaction
    @ObservedObject var transactionStore = TransactionStore.shared
    @ObservedObject var category: SpendCraft.Category
    @State var isEditingTrx = false
    var postedTransaction: Bool
    
    func formatAccount(institution: String?, account: String?) -> String {
        guard let institution = institution, let account = account else {
            return ""
        }
        
        if (institution != "" && account != "") {
            return "\(institution): \(account)"
        }
        
        return ""
    }

    var body: some View {
        Button {
            Task {
                isEditingTrx = true
            }
        } label: {
            VStack(spacing: 10) {
                HStack() {
                    HStack {
                        Text(trx.name)
                            .lineLimit(1)
                        Spacer()
                    }
                    SpendCraft.AmountView(amount: trx.categoryAmount(category: category))
                }
                
                HStack {
                    Text(formatDate(date: trx.date))
                    Spacer()
                    if let runningBalance = trx.runningBalance {
                        SpendCraft.AmountView(amount: runningBalance)
                    }
                }
                .font(.caption)
            }
        }
        .sheet(isPresented: $isEditingTrx) {
            FundingEdit(transaction: trx, isOpen: $isEditingTrx)
        }
    }
}

//struct FundingTransactionView_Previews: PreviewProvider {
//    static var previews: some View {
//        FundingTransactionView()
//    }
//}
