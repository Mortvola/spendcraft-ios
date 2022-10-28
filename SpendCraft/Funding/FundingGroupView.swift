//
//  FundingGroupView.swift
//  SpendCraft
//
//  Created by Richard Shields on 10/26/22.
//

import SwiftUI
import Framework

struct FundingGroupView: View {
    @ObservedObject var group: SpendCraft.Group
    @State var isExpanded = true
    @Binding var trxData: Transaction.Data
    
    var body: some View {
        DisclosureGroup(group.name, isExpanded: $isExpanded) {
            ForEach($group.categories) { $category in
                FundingCategoryView(category: category, trxData: $trxData)
            }
        }
    }
}

//struct FundingGroupView_Previews: PreviewProvider {
//    static let group = SpendCraft.Group(id: 0, name: "Test Group", type: .regular, categories: [])
//    static let categoryDictionary = Dictionary<Int, Category>()
//
//    static var previews: some View {
//        FundingGroupView(group: group, trxData: .constant(SampleData.transactions[0].data))
//    }
//}
