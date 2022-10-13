//
//  EditCategoriesView.swift
//  SpendCraft
//
//  Created by Richard Shields on 10/12/22.
//

import SwiftUI
import Framework

struct EditCategoriesView: View {
    @ObservedObject var categoriesStore = CategoriesStore.shared
    @Binding var isEditingCategories: Bool
    @State private var isAddingCategory = false
    @State private var isAddingGroup = false

    var body: some View {
        NavigationStack {
            VStack {
                List() {
                    Section(header: Text("My Categories")) {
                        ForEach(categoriesStore.tree) { node in
                            switch node {
                            case .category(let category):
                                CategoryView2(category: category)
                            case .group(let group):
                                if (group.type != GroupType.system) {
                                    GroupView2(group: group)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Edit Categories")
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button("Add Group") { isAddingGroup = true }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button("Add Category") { isAddingCategory = true }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        isEditingCategories = false;
                    }
                }
            }
            .sheet(isPresented: $isAddingGroup) {
                AddGroupView(isOpen: $isAddingGroup)
                    .presentationDetents([.medium])
            }
            .sheet(isPresented: $isAddingCategory) {
                AddCategoryView(isOpen: $isAddingCategory)
                    .presentationDetents([.medium])
            }
        }
    }
}

struct EditCategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        EditCategoriesView(isEditingCategories: .constant(true))
    }
}
