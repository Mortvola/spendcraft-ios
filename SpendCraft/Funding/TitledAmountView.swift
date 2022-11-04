//
//  TitledAmountView.swift
//  SpendCraft
//
//  Created by Richard Shields on 11/3/22.
//

import SwiftUI
import Framework

struct TitledAmountView: View {
    var title: String
    var amount: Double
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text(title)
            }
            .padding(.bottom, 2)
            HStack {
                Spacer()
                SpendCraft.AmountView(amount: amount)
            }
        }
    }
}

struct TitledAmountView_Previews: PreviewProvider {
    static var previews: some View {
        TitledAmountView(title: "Current", amount: 10000.0)
    }
}
