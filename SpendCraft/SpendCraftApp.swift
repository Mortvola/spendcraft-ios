//
//  SpendCraftApp.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/15/22.
//

import SwiftUI

@main
struct SpendCraftApp: App {
    @StateObject private var authentication = Authentication()

    var body: some Scene {
        WindowGroup {
            if (authentication.authenticated) {
                MainView()
            }
            else {
                LoginView(authenticated: $authentication.authenticated)
            }
        }
    }
}
