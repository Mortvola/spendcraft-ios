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
    @StateObject private var testCategory = SpendCraft.Category(id: -2, groupId: 0, name: "Unassigned", balance: 100, type: .regular, monthlyExpenses: false)
    @State private var isEditingCategories = false
    @State private var isFundingCategories = false
    @State private var newTransaction = Transaction(type: .regular)
    @State var trxData = Transaction.Data()

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
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Fund") {
                        newTransaction = Transaction(type: .funding)
                        newTransaction.data() { d in
                            trxData = d
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
            FundingEdit(transaction: newTransaction, isOpen: $isFundingCategories, trxData: $trxData)
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
