//
//  CategoriesView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/18/22.
//

import SwiftUI

struct CategoriesView: View {
    @StateObject private var categoriesStore = CategoriesStore();
    @StateObject var testCategory = Categories.Category(id: -2, groupId: 0, name: "Unassigned", balance: 100, type: .regular, monthlyExpenses: false)
    
    func loadCategories() {
        CategoriesStore.load(completion: { result in
            switch result {
            case .failure(let error):
                fatalError(error.localizedDescription)
            case .success(let categories):
                self.categoriesStore.categories = categories
            }
        })
    }

    var body: some View {
        NavigationView {
            List {
                CategoryView(category: categoriesStore.categories.unassigned, categories: $categoriesStore.categories)
                CategoryView(category: categoriesStore.categories.fundingPool, categories: $categoriesStore.categories)
                CategoryView(category: categoriesStore.categories.accountTransfer, categories: $categoriesStore.categories)
                NavigationLink(destination: RegisterView(category: testCategory, categories: $categoriesStore.categories)) {
                    Text("Rebalances")
                }
                Divider()
                ForEach($categoriesStore.categories.tree) { $node in
                    switch node {
                    case .category(let category):
                        CategoryView(category: category, categories: $categoriesStore.categories)
                    case .group(let group):
                        if (group.type != GroupType.system) {
                            GroupView(group: .constant(group), categories: $categoriesStore.categories)
                        }
                    }
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("Categories")
            .refreshable {
                loadCategories()
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
