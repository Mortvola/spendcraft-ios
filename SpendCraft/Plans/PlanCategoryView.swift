//
//  CategoryView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/20/22.
//

import SwiftUI
import Framework

struct PlanCategoryView: View {
    @ObservedObject var category: SpendCraft.Category
    @ObservedObject var planCategory: PlanCategory

    var body: some View {
        NavigationLink(value: category) {
            VStack {
                HStack {
                    Text(category.name)
                    Spacer()
                    SpendCraft.AmountView(amount: planCategory.amount / Double(planCategory.recurrence))
                }
                if planCategory.recurrence > 1 {
                    HStack {
                        Text("\(SpendCraft.Amount(amount: planCategory.amount)) due in")
                        Spacer()
                    }
                    .font(.caption)
                }
            }
        }
    }
}

struct PlanCategoryView_Previews: PreviewProvider {
    static let category = SpendCraft.Category(id: 0, groupId: 0, name: "Test Category", balance: 100, type: .regular, monthlyExpenses: true, hidden: false)
//    static let plan = Response.Plan(id: 0, name: "test", categories: [Response.PlanCategory(id: 0, categoryId: 0, amount: 100.0, recurrence: 1)])
    static let planCategory = PlanCategory(response: Response.PlanCategory(id: 0, categoryId: 0, amount: 100.0, recurrence: 12, useGoal: false, goalDate: Date.now, expectedToSpend: nil))

    static var previews: some View {
        PlanCategoryView(category: category, planCategory: planCategory)
    }
}
