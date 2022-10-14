//
//  SpendCraftApp.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/15/22.
//

import SwiftUI
import Framework

@main
struct SpendCraftApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    @StateObject private var authenticator = Authenticator()
    @Environment(\.scenePhase) var scenePhase
    @State var isActive = false
    @State var tabSelection: TabSelection = .categories
    
    func registerForPushNotifications() {
      UNUserNotificationCenter.current()
        .requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
          print("Permission granted: \(granted)")
          guard granted else { return }
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                guard settings.authorizationStatus == .authorized else { return }
                DispatchQueue.main.async {
                    print("registering for remote notifications")
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }

    var opacity: Double {
        scenePhase == .active ? 0 : 1
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                if (authenticator.authenticated) {
                    MainView(authenticator: authenticator, selection: $tabSelection)
                        .onAppear {
                            registerForPushNotifications()
                        }
                } else {
                    LoginView(authenticator: authenticator)
                }
                InactiveView()
                    .opacity(opacity)
            }
            .animation(.easeInOut(duration: 0.25), value: opacity)
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                self.isActive = true
            case .inactive:
                if (!self.isActive && !authenticator.authenticated) {
                    // Transitioning from background to active state, attempt signIn
                    do {
                        let (username, password) = try authenticator.getCredentials()
                        authenticator.signIn(username: username, password: password)
                        tabSelection = .categories
                    }
                    catch {
                    }
                }
            case .background:
                self.isActive = false
            @unknown default:
                print("scenePhse unexpected state")
            }
        }
        .onChange(of: authenticator.authenticated) { authenticated in
            // If we sign out then set the tab selection back to categories
            if (!authenticated) {
                tabSelection = .categories
            }
        }
    }
}
