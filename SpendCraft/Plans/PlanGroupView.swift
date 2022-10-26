//
//  GroupView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/20/22.
//

import SwiftUI
import Framework

struct PlanGroupView: View {
    @ObservedObject var group: SpendCraft.Group
    @State var isExpanded: Bool = true
    @ObservedObject var planStore = PlanStore.shared
    
    var body: some View {
        DisclosureGroup(group.name, isExpanded: $isExpanded) {
            ForEach($group.categories) { $category in
                PlanCategoryView(category: category, planCategory: planStore.planCategory(category))
            }
        }
    }
}

struct PlanGroupView_Previews: PreviewProvider {
    static let group = SpendCraft.Group(id: 0, name: "Test Group", type: .regular, categories: [])
    static let categoryDictionary = Dictionary<Int, Category>()
    static let plan = Response.Plan(id: 0, name: "test", categories: [Response.PlanCategory(id: 0, categoryId: 0, amount: 100.0, recurrence: 1, useGoal: false, goalDate: Date.now)])

    static var previews: some View {
        PlanGroupView(group: group)
    }
}
