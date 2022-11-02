//
//  FundingNew.swift
//  SpendCraft
//
//  Created by Richard Shields on 11/2/22.
//

import SwiftUI

struct FundingNew: View {
    @StateObject var transaction = Transaction(type: .funding)
    @Binding var isOpen: Bool
    
    var body: some View {
        FundingEdit(transaction: transaction, isOpen: $isOpen)
    }
}

struct FundingNew_Previews: PreviewProvider {
    static var previews: some View {
        FundingNew(isOpen: .constant(true))
    }
}
