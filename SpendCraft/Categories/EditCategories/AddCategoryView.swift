//
//  AddCategoryView.swift
//  SpendCraft
//
//  Created by Richard Shields on 10/12/22.
//

import SwiftUI

struct AddCategoryView: View {
    @Binding var isOpen: Bool
    @State var name: String = ""
    @State var groupId: Int = CategoriesStore.shared.noGroupId
    var categoriesStore = CategoriesStore.shared
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
            }
            .navigationTitle("Add Category")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isOpen = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        isOpen = false;
                        categoriesStore.addCategory(name: name, groupId: groupId)
                    }
                    disabled(name.isEmpty)
                }
            }
            .onAppear {
                nameInFocus = true
            }
        }
    }
}

struct AddCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        AddCategoryView(isOpen: .constant(true))
    }
}
