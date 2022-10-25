//
//  PlanItem.swift
//  SpendCraft
//
//  Created by Richard Shields on 10/19/22.
//

import SwiftUI
import Framework

let months: [String] = [
    "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"
]

struct PlanItemEdit: View {
    var category: SpendCraft.Category
    var planCategory: PlanCategory
    var planStore = PlanStore.shared
    @State var data: PlanCategory.Data = PlanCategory.Data()
    @State var starting: Int = 0
    @Binding var isEditing: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                HStack {
                    Text("Amount:")
                    NumericField(value: $data.amount)
                    Spacer()
                }
                
                Stepper(value: $data.recurrence, in: 1...360, step:  1) {
                    Text(data.recurrence == 1
                         ? "Occurs each month"
                         : "Occurs every \(data.recurrence) months")
                }
                
                if (data.recurrence > 1) {
                    HStack {
                        Text("Monthly amount of")
                        SpendCraft.AmountView(amount: (data.amount ?? 0) / Double(data.recurrence))
                        Spacer()
                    }
                    
                    ControlGroup {
                        Picker("Month", selection: $data.goalMonth) {
                            ForEach(0..<12) { m in
                                Text(months[m]).tag(m + 1)
                            }
                        }
                        
                        Picker("Year", selection: $data.goalYear) {
                            ForEach(0..<30) { y in
                                Text("\(2022 + y)").tag(2022 + y)
                            }
                        }
                    } label: {
                        Text("Next Expense Date")
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
                        do {
                            try planCategory.save(data: data)
                            
                            planStore.plan?.total += (data.amount ?? 0) / Double(data.recurrence) - (planCategory.amount / Double(planCategory.recurrence))
                            
                            isEditing = false;
                        }
                        catch {
                        }
                    }
    //                .disabled(!trxData.isValid || !postedTransaction)
                }
            }
            .onAppear {
                data = try! planCategory.data()
            }
        }
    }
}

struct PlanItemEdit_Previews: PreviewProvider {
    static let planCategory = PlanCategory(response: Response.PlanCategory(id: 0, categoryId: 0, amount: 100.0, recurrence: 12, useGoal: false))
    static let data = try! PlanCategory.Data(amount: 100.0, recurrence: 2, goalDate: nil)
    static let category = SpendCraft.Category(id: 0, groupId: 0, name: "Test", balance: 10.0, type: .regular, monthlyExpenses: false)
    static var previews: some View {
        PlanItemEdit(category: category, planCategory: planCategory, data: data, isEditing: .constant(false))
    }
}
