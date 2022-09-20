//
//  CategoriesView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/18/22.
//

import SwiftUI

struct CategoriesView: View {
    @Binding var categories: Categories
    @State var testCategory = Category(id: -2, groupId: 0, name: "Unassigned", balance: 100, type: "REGULAR", monthlyExpenses: false)

    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: RegisterView(category: $testCategory)) {
                    Text("Unassigned")
                }
                NavigationLink(destination: RegisterView(category: $testCategory)) {
                    Text("Funding Pool")
                }
                NavigationLink(destination: RegisterView(category: $testCategory)) {
                    Text("Account Transfer")
                }
                NavigationLink(destination: RegisterView(category: $testCategory)) {
                    Text("Rebalances")
                }
                Divider()
                ForEach($categories.tree) { $node in
                    switch node {
                    case .category(let category):
                        CategoryView(category: .constant(category))
                    case .group(let group):
                        GroupView(group: .constant(group))
                    }
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("Categories")
        }
    }
}

struct CategoriesView_Previews: PreviewProvider {
    static let categories = Categories(tree: [])

    static var previews: some View {
        CategoriesView(categories: .constant(categories))
    }
}
