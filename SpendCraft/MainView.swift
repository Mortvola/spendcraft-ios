//
//  Main.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/18/22.
//

import SwiftUI
import Framework

struct MainView: View {
    @ObservedObject var authenticator: Authenticator
    @ObservedObject var categoriesStore = CategoriesStore.shared
    @Binding var selection: String
    @StateObject private var navModel = NavModel()
    @SceneStorage("navigation") private var navigationData: Data?
    @State var isConfiguringWidget = false
    @StateObject var categories = CatList()
    
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
        .sheet(isPresented: $isConfiguringWidget) {
            ConfigureWidgetView(isConfiguringWidget: $isConfiguringWidget, categories: categories)
        }
        .environmentObject(navModel)
        .task {
            if let jsonData = navigationData {
                navModel.jsonData = jsonData
            }
            
            for await _ in navModel.objectWillChangeSequence {
                navigationData = navModel.jsonData
            }
        }
        .onOpenURL { url in
            if (url.path() == "/widget/configure") {
                let catIds = SpendCraft.readWatchList()
                
                categories.categories = catIds.map {
                    Cat(id: $0)
                }
                
                isConfiguringWidget = true
            }
        }
    }
}

struct Main_Previews: PreviewProvider {
    static let authenticator = Authenticator()
    static let selection: String = "categories"
    
    static var previews: some View {
        MainView(authenticator: authenticator, selection: .constant(selection))
    }
}
