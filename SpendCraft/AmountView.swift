//
//  AmountView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/20/22.
//

import SwiftUI

struct AmountView: View {
    var amount: Double
    
    func format(value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.currency
        
        let number = NSNumber(value: value)
        return formatter.string(from: number) ?? ""
    }
    
    var body: some View {
        Text(format(value: amount))
            .foregroundColor(amount < 0 ? Color(.red) : nil)
            .monospacedDigit()
    }
}

struct AmountView_Previews: PreviewProvider {
    static var previews: some View {
        AmountView(amount: 100)
    }
}
