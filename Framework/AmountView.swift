//
//  AmountView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/20/22.
//

import SwiftUI

extension SpendCraft {
    public struct AmountView: View {
        public var amount: Double
        
        public init(amount: Double) {
            self.amount = amount
        }
        
        func format(value: Double) -> String {
            let formatter = NumberFormatter()
            formatter.numberStyle = NumberFormatter.Style.currency
            
            var v = value
            if (v == 0.0 && v.sign == .minus) {
                v = 0.0
            }

            let number = NSNumber(value: v)
            return formatter.string(from: number) ?? ""
        }
        
        public var body: some View {
            Text(format(value: amount))
                .foregroundColor(amount < 0 ? Color(.red) : nil)
                .monospacedDigit()
        }
    }
}

struct AmountView_Previews: PreviewProvider {
    static var previews: some View {
        SpendCraft.AmountView(amount: 100)
    }
}
