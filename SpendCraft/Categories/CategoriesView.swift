//
//  CategoriesView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/18/22.
//

import SwiftUI
import Framework

struct CategoriesView: View {
    @ObservedObject private var categoriesStore = CategoriesStore.shared
    @EnvironmentObject private var navModel: NavModel
    @StateObject private var testCategory = SpendCraft.Category(id: -2, groupId: 0, name: "Unassigned", balance: 100, type: .regular, monthlyExpenses: false, hidden: false)
    @State private var isEditingCategories = false
    @State private var isFundingCategories = false

    var body: some View {
        NavigationSplitView {
            List(selection: $navModel.selectedCategory) {
                Section(header: Text("System Categories")) {
                    CategoryView(category: categoriesStore.unassigned)
                    CategoryView(category: categoriesStore.fundingPool)
                    CategoryView(category: categoriesStore.accountTransfer)
                    NavigationLink(destination: RegisterView(category: testCategory)) {
                        Text("Category Transfers")
                    }
                }
                
                Section(header: Text("My Categories")) {
                    ForEach(categoriesStore.tree) { node in
                        switch node {
                        case .category(let category):
                            if !category.hidden {
                                CategoryView(category: category)
                            }
                        case .group(let group):
                            if (!group.hidden && group.type != GroupType.system) {
                                GroupView(group: group)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Categories")
            .refreshable {
                await categoriesStore.load(force: true)
            }
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Fund") {
                        Task {
                            isFundingCategories = true
                        }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Edit") {
                        isEditingCategories = true
                    }
                }
            }
        } detail: {
            if let category = navModel.selectedCategory {
                RegisterView(category: category)
            }
        }
        .sheet(isPresented: $isEditingCategories) {
            EditCategoriesView(isEditingCategories: $isEditingCategories)
                .presentationDetents([.large])
        }
        .sheet(isPresented: $isFundingCategories) {
            FundingNew(isOpen: $isFundingCategories)
        }
    }
}

struct CategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        CategoriesView()
    }
}
