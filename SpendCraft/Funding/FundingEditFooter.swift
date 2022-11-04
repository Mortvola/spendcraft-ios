//
//  FundingEditFooter.swift
//  SpendCraft
//
//  Created by Richard Shields on 11/2/22.
//

import SwiftUI
import Framework

struct FundingEditFooter: View {
    @Binding var trxData: FundingTransaction.Data
    var categoriesStore = CategoriesStore.shared
    
    func current() -> Double {
        guard let transaction = trxData.transaction else {
            return categoriesStore.fundingPool.balance
        }
        
        if (transaction.id < 0) {
            return categoriesStore.fundingPool.balance
        }

        let funding = transaction.categories.first {
            $0.categoryId == categoriesStore.fundingPool.id
        }
        
        return categoriesStore.fundingPool.balance - (funding?.amount ?? 0)
    }

    var body: some View {
        VStack {
            LabeledContent("Funding Pool") {
                SpendCraft.AmountView(amount: current())
            }
            LabeledContent("Funding Total") {
                SpendCraft.AmountView(amount: trxData.fundingTotal)
            }
            LabeledContent("Funding Pool Balance") {
                SpendCraft.AmountView(amount: current() - trxData.fundingTotal)
            }
            LabeledContent("Expected Total") {
                SpendCraft.AmountView(amount: trxData.allowedTotal)
            }
            .padding(.top)
        }
        .padding()
        .border(edge: .top)
    }
}

struct FundingEditFooter_Previews: PreviewProvider {
    static var data = FundingTransaction.Data()
    
    static var previews: some View {
        FundingEditFooter(trxData: .constant(data))
    }
}
