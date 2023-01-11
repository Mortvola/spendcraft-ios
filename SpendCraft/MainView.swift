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
    @StateObject private var navModel = NavModel.shared
    @SceneStorage("navigation") private var navigationData: Data?
    @State var isConfiguringWidget = false
    @StateObject var categories = CatList()
    
    var selectionHandler: Binding<TabSelection> { Binding(
        get: { navModel.tabSelection },
        set: {
            if $0 == navModel.tabSelection {
                // If the tab is not changing then change the view
                // to that of the root for the tab.
                switch navModel.tabSelection {
                case TabSelection.categories:
                    navModel.selectedCategory = nil
                case TabSelection.plans:
                    navModel.selectedPlanCategory = nil
                    break;
                case TabSelection.accounts:
                    navModel.selectedAccount = nil
                    break;
                case TabSelection.settings:
                    break;
                }
            }

            navModel.tabSelection = $0
        }
    )}
 
    var body: some View {
        TabView(selection: selectionHandler) {
            CategoriesView()
                .tabItem {
                    Label("Categories", systemImage: "tray.and.arrow.down.fill")
                }
                .tag(TabSelection.categories)
            PlansView()
                .tabItem {
                    Label("Plans", systemImage: "map")
                }
                .tag(TabSelection.plans)
            AccountsView()
                .tabItem {
                    Label("Accounts", systemImage: "building.columns")
                }
                .tag(TabSelection.accounts)
            ReportsView()
                .tabItem {
                    Label("Reports", systemImage: "doc.on.doc")
                }
                .tag("reports")
            SettingsView(authenticator: authenticator)
                .tabItem {
                    Label("Account", systemImage: "person.crop.circle")
                }
                .tag(TabSelection.settings)
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
    
    static var previews: some View {
        MainView(authenticator: authenticator)
    }
}
