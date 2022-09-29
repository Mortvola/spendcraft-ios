//
//  Main.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/18/22.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            CategoriesView()
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
    }
}

struct Main_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
