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
    @Environment(\.scenePhase) var scenePhase
    @StateObject private var navModel = NavModel.shared
    @ObservedObject var busy = Busy.shared
    @ObservedObject private var categoriesStore = CategoriesStore.shared
    @ObservedObject private var authenticator = Authenticator.shared

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
                ZStack {
                    if (authenticator.authenticated) {
                        MainView(authenticator: authenticator)
                            .onAppear {
                                registerForPushNotifications()
                            }
                    } else {
                        LoginView()
                    }
                }

                if busy.busy {
                    ProgressView()
                        .padding(32)
                        .background(Color(.white))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(.gray, lineWidth: 1))
                }
                InactiveView()
                    .opacity(opacity)
            }
            .animation(.easeInOut(duration: 0.25), value: opacity)
        }
        .onChange(of: authenticator.authenticated) { authenticated in
            // If we sign out then set the tab selection back to categories
            if (!authenticated) {
                navModel.tabSelection = .categories
            }
            else {
                Task {
                    await categoriesStore.load(force: true)
                }
            }
        }
    }
}
