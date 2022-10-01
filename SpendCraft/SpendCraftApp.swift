//
//  SpendCraftApp.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/15/22.
//

import SwiftUI

@main
struct SpendCraftApp: App {
    @StateObject private var authenticator = Authenticator()
    @Environment(\.scenePhase) var scenePhase
    @State var isActive = false
    @State var tabSelection: String = "categories"
    
    var body: some Scene {
        WindowGroup {
            if (scenePhase == .inactive) {
                InactiveView()
            }
            else if (authenticator.authenticated) {
                MainView(authenticator: authenticator, selection: $tabSelection)
            }
            else {
                LoginView(authenticator: authenticator)
            }
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                self.isActive = true
            case .inactive:
                if (!self.isActive && !authenticator.authenticated) {
                    // Transitioning from background to active state, attempt signIn
                    do {
                        let (username, password) = try Authenticator.getCredentials()
                        authenticator.signIn(username: username, password: password)
                        tabSelection = "categories"
                    }
                    catch {
                    }
                }
            case .background:
                self.isActive = false
            @unknown default:
                print("scenePhse unexpted state")
            }
        }
        .onChange(of: authenticator.authenticated) { authenticated in
            // If we sign out then set the tab selection back to categories
            if (!authenticated) {
                tabSelection = "categories"
            }
        }
    }
}
