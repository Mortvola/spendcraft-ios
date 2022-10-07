//
//  CategoriesView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/18/22.
//

import SwiftUI

struct CategoriesView: View {
    @EnvironmentObject private var categoriesStore: CategoriesStore
    @StateObject var testCategory = CategoriesStore.Category(id: -2, groupId: 0, name: "Unassigned", balance: 100, type: .regular, monthlyExpenses: false)
    @StateObject var navModel = NavModel()

    func loadCategories() {
        categoriesStore.load()
    }

    var body: some View {
        NavigationSplitView {
            List(selection: $navModel.selectedCategory) {
                CategoryView(category: categoriesStore.unassigned)
                CategoryView(category: categoriesStore.fundingPool)
                CategoryView(category: categoriesStore.accountTransfer)
                NavigationLink(destination: RegisterView(category: testCategory)) {
                    Text("Rebalances")
                }
                Divider()
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
            .navigationTitle("Categories")
            .refreshable {
                loadCategories()
            }
        } detail: {
            if let category = navModel.selectedCategory {
                RegisterView(category: category)
            }
        }
        .onAppear {
            loadCategories()
        }
    }
}

struct CategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        CategoriesView()
    }
}
