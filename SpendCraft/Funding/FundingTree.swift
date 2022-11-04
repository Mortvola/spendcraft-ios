//
//  FundingTree.swift
//  SpendCraft
//
//  Created by Richard Shields on 11/3/22.
//

import SwiftUI
import Framework

struct FundingTree: View {
    var categoriesStore = CategoriesStore.shared
    @Binding var trxData: Transaction.Data
    @Binding var showPopover: Int?

    var body: some View {
        List(categoriesStore.tree) { node in
            switch node {
            case .category(let category):
                FundingCategoryView(category: category, trxData: $trxData, adjusted: false, adjustedText: "", showPopover: $showPopover)
            case .group(let group):
                if !group.hidden && group.type != GroupType.system {
                    FundingGroupView(group: group, trxData: $trxData, showPopover: $showPopover)
                }
            }
        }
    }
}

struct FundingTree_Previews: PreviewProvider {
    static var previews: some View {
        FundingTree(trxData: .constant(Transaction.Data()), showPopover: .constant(0))
    }
}
