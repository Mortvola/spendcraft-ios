//
//  FundingEditFooter.swift
//  SpendCraft
//
//  Created by Richard Shields on 11/2/22.
//

import SwiftUI
import Framework

struct FundingEditFooter: View {
    @Binding var trxData: Transaction.Data
    var categoriesStore = CategoriesStore.shared
    
    var body: some View {
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
}

struct FundingEditFooter_Previews: PreviewProvider {
    static var data = Transaction.Data()
    
    static var previews: some View {
        FundingEditFooter(trxData: .constant(data))
    }
}
