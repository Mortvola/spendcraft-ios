//
//  PlanItem.swift
//  SpendCraft
//
//  Created by Richard Shields on 10/19/22.
//

import SwiftUI
import Framework

struct PlanItemEdit: View {
    var category: SpendCraft.Category
    var planCategory: PlanCategory
    var planStore = PlanStore.shared
    @State var data = PlanCategory.Data()
    @State var starting: Int = 0
    @Binding var isEditing: Bool
    @State var selectDate = false
    
    func dateLabel() -> String {
        if let date = data.goal {
            return "\(months[date.month - 1]) \(date.year)"
        }
        
        return "No Date"
    }

    var body: some View {
        NavigationStack {
            Form {
                HStack {
                    LabeledContent("Amount:") {
                        NumericField(value: $data.amount)
                    }
                }
                
                Stepper(value: $data.recurrence, in: 1...360, step:  1) {
                    Text(data.recurrence == 1
                         ? "Occurs each month"
                         : "Occurs every \(data.recurrence) months")
                }
                
                if (data.recurrence > 1) {
                    HStack {
                        LabeledContent("Monthly amount of") {
                            SpendCraft.AmountView(amount: (data.amount ?? 0) / Double(data.recurrence))
                        }
                    }
                    
                    ControlGroup {
                        LabeledContent("Next Expense Date") {
                            Button(action: { selectDate = true }) {
                                Spacer()
                                Text(dateLabel())
                                Spacer()
                            }
                        }
                    }
                }
                
                ControlGroup {
                    LabeledContent("Expected to Spend") {
                        NumericField(value: $data.expectedToSpend)
                    }
                }
            }
            .navigationTitle(category.name)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isEditing = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        Task {
                            try await planCategory.save(data: data)
                            
                            planStore.plan?.total += (data.amount ?? 0) / Double(data.recurrence) - (planCategory.amount / Double(planCategory.recurrence))
                            
                            isEditing = false;
                        }
                    }
    //                .disabled(!trxData.isValid || !postedTransaction)
                }
            }
            .onAppear {
                data = try! planCategory.data()
            }
            .sheet(isPresented: $selectDate) {
                MonthYearPicker(date: $data.goal, isOpen: $selectDate)
            }
        }
    }
}

struct PlanItemEdit_Previews: PreviewProvider {
    static let planCategory = PlanCategory(response: Response.PlanCategory(id: 0, categoryId: 0, amount: 100.0, recurrence: 12, useGoal: false, goalDate: Date.now, expectedToSpend: nil))
    static let category = SpendCraft.Category(id: 0, groupId: 0, name: "Test", balance: 10.0, type: .regular, monthlyExpenses: false, hidden: false)
    static var previews: some View {
        PlanItemEdit(category: category, planCategory: planCategory, isEditing: .constant(false))
    }
}
