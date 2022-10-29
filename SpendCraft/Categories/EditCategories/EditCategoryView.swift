//
//  EditCategoryView.swift
//  SpendCraft
//
//  Created by Richard Shields on 10/12/22.
//

import SwiftUI
import Framework

struct EditCategoryView: View {
    var categoriesStore = CategoriesStore.shared
    @ObservedObject var category: SpendCraft.Category
    @Binding var isOpen: Bool
    @State private var name: String = ""
    @State private var groupId: Int = CategoriesStore.shared.noGroupId
    @FocusState private var nameInFocus: Bool

    var body: some View {
        NavigationStack {
            Form {
                LabeledContent("Name") {
                    TextField("Name", text: $name)
                        .multilineTextAlignment(.trailing)
                        .lineLimit(1)
                        .focused($nameInFocus)
                }
                Picker("Group", selection: $groupId) {
                    Text("None").tag(CategoriesStore.shared.noGroupId)
                    ForEach(categoriesStore.groups()) { g in
                        Text(g.name)
                    }
                }
                ControlGroup {
                    DeleteButton()  {
                        isOpen = false
                        categoriesStore.deleteCategory(category: category)
                    }
                }
            }
            .navigationTitle("Edit Category")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isOpen = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        Task {
                            await categoriesStore.updateCategory(category: category, name: name, groupId: groupId)
                            isOpen = false
                        }
                    }
                    .disabled(name.isEmpty)
                }
            }
            .onAppear {
                name = category.name
                groupId = category.groupId
                
                nameInFocus = true
            }
        }
    }
}

struct EditCategoryView_Previews: PreviewProvider {
    static let category = SpendCraft.Category(id: 0, groupId: 0, name: "Test", balance: 100.0, type: .regular, monthlyExpenses: true)

    static var previews: some View {
        EditCategoryView(category: category, isOpen: .constant(true))
    }
}
