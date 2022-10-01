//
//  Main.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/18/22.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var authenticator: Authenticator
    @Binding var selection: String

    var body: some View {
        TabView(selection: $selection) {
            CategoriesView()
                .tabItem {
                    Label("Categories", systemImage: "tray.and.arrow.down.fill")
                }
                .tag("categories")
            PlansView()
                .tabItem {
                    Label("Plans", systemImage: "map")
                }
                .tag("plans")
            AccountsView()
                .tabItem {
                    Label("Accounts", systemImage: "building.columns")
                }
                .tag("accounts")
            ReportsView()
                .tabItem {
                    Label("Reports", systemImage: "doc.on.doc")
                }
                .tag("reports")
            SettingsView(authenticator: authenticator)
                .tabItem {
                    Label("Account", systemImage: "person.crop.circle")
                }
                .tag("settings")
        }
    }
}

struct Main_Previews: PreviewProvider {
    static let authentication = Authenticator()
    static let selection: String = "categories"
    
    static var previews: some View {
        MainView(authenticator: authentication, selection: .constant(selection))
    }
}
