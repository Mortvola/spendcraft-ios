//
//  CategoriesView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/18/22.
//

import SwiftUI
import Framework

struct CategoriesView: View {
    @ObservedObject var categoriesStore = CategoriesStore.shared
    @EnvironmentObject private var navModel: NavModel
    @StateObject var testCategory = SpendCraft.Category(id: -2, groupId: 0, name: "Unassigned", balance: 100, type: .regular, monthlyExpenses: false)
    @State var isAddingCategory = false
    @State var isAddingGroup = false
    
    var body: some View {
        NavigationSplitView {
            HStack {
                Button(action: { isAddingCategory = true }) {
                    Text("Add Category")
                }
                Button(action: { isAddingGroup = true }) {
                    Text("Add Group")
                }
            }
            List(selection: $navModel.selectedCategory) {
                Section(header: Text("System Categories")) {
                    CategoryView(category: categoriesStore.unassigned)
                    CategoryView(category: categoriesStore.fundingPool)
                    CategoryView(category: categoriesStore.accountTransfer)
                    NavigationLink(destination: RegisterView(category: testCategory)) {
                        Text("Rebalances")
                    }
                }
                
                Section(header: Text("My Categories")) {
                    ForEach(categoriesStore.tree) { node in
                        switch node {
                        case .category(let category):
                            CategoryView(category: category)
                        case .group(let group):
                            if (group.type != GroupType.system) {
                                GroupView(group: group)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Categories")
            .refreshable {
                categoriesStore.load()
            }
        } detail: {
            if let category = navModel.selectedCategory {
                RegisterView(category: category)
            }
        }
        .sheet(isPresented: $isAddingCategory) {
            AddCategoryView(isAddingCategory: $isAddingCategory)
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $isAddingGroup) {
            AddGroupView(isAddingGroup: $isAddingGroup)
                .presentationDetents([.medium])
        }
        .onAppear {
            if (!categoriesStore.loaded) {
                categoriesStore.load()
            }
        }
    }
}

struct CategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        CategoriesView()
    }
}
