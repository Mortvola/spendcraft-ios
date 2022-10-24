//
//  AmountView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/20/22.
//

import SwiftUI

extension SpendCraft {
    public static func Amount(amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.numberStyle = .decimal
        
        var v = amount
        if (v == 0.0 && v.sign == .minus) {
            v = 0.0
        }

        let number = NSNumber(value: v)
        return formatter.string(from: number) ?? ""
    }
    
    public struct AmountView: View {
        public var amount: Double
        
        public init(amount: Double) {
            self.amount = amount
        }
        
        public var body: some View {
            Text(Amount(amount: amount))
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
