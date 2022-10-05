//
//  CategoriesView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/18/22.
//

import SwiftUI

struct CategoriesView: View {
    @Binding var categories: Categories
    @StateObject var testCategory = Categories.Category(id: -2, groupId: 0, name: "Unassigned", balance: 100, type: .regular, monthlyExpenses: false)
    
    func loadCategories() {
        CategoriesStore.load(completion: { result in
            switch result {
            case .failure(let error):
                fatalError(error.localizedDescription)
            case .success(let categories):
                self.categories = categories
            }
        })
    }

    var body: some View {
        NavigationView {
            List {
                CategoryView(category: categories.unassigned, categories: $categories)
                CategoryView(category: categories.fundingPool, categories: $categories)
                CategoryView(category: categories.accountTransfer, categories: $categories)
                NavigationLink(destination: RegisterView(category: testCategory, categories: $categories)) {
                    Text("Rebalances")
                }
                Divider()
                ForEach($categories.tree) { $node in
                    switch node {
                    case .category(let category):
                        CategoryView(category: category, categories: $categories)
                    case .group(let group):
                        if (group.type != GroupType.system) {
                            GroupView(group: .constant(group), categories: $categories)
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
        CategoriesView(categories: .constant(SampleData.categories))
    }
}
