//
//  PlanItemView.swift
//  SpendCraft
//
//  Created by Richard Shields on 10/21/22.
//

import SwiftUI
import Framework

struct PlanItemView: View {
    var category: SpendCraft.Category
    @ObservedObject var planCategory: PlanCategory
    @State var isEditing = false

    var body: some View {
        Button(action: {
            isEditing = true
        }) {
            HStack {
                Text(planCategory.recurrence == 1
                     ? "Occurs each month"
                     : "\(SpendCraft.Amount(amount: planCategory.amount)) every \(planCategory.recurrence) months")
                Spacer()
                SpendCraft.AmountView(amount: planCategory.amount / Double(planCategory.recurrence))
            }
            .padding([.leading, .trailing])
        }
        .navigationTitle(category.name)
        .sheet(isPresented: $isEditing) {
            PlanItemEdit(category: category, planCategory: planCategory, isEditing: $isEditing)
        }
    }
}

struct PlanItemView_Previews: PreviewProvider {
    static let planCategory = PlanCategory(response: Response.PlanCategory(id: 0, categoryId: 0, amount: 100.0, recurrence: 1, useGoal: false, goalDate: Date.now, expectedToSpend: nil))
    static let category = SpendCraft.Category(id: 0, groupId: 0, name: "Test", balance: 10.0, type: .regular, monthlyExpenses: false, hidden: false)

    static var previews: some View {
        PlanItemView(category: category, planCategory: planCategory)
    }
}
