//
//  Main.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/18/22.
//

import SwiftUI

struct MainView: View {
    @StateObject private var categoriesStore = CategoriesStore();

    var body: some View {
        TabView {
            CategoriesView(categories: $categoriesStore.categories)
                .tabItem {
                    Label("Categories", systemImage: "tray.and.arrow.down.fill")
                }
            PlansView()
                .tabItem {
                    Label("Plans", systemImage: "map")
                }
            AccountsView()
                .tabItem {
                    Label("Accounts", systemImage: "building.columns")
                }
            ReportsView()
                .tabItem {
                    Label("Reports", systemImage: "doc.on.doc")
                }
        }
        .onAppear {
            CategoriesStore.load(completion: { result in
                switch result {
                case .failure(let error):
                    fatalError(error.localizedDescription)
                case .success(let categories):
                    self.categoriesStore.categories = categories
                }
            })
        }
    }
}

struct Main_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
