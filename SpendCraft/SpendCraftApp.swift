//
//  SpendCraftApp.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/15/22.
//

import SwiftUI
import SpendCraftFramework

enum Identifiers {
  static let viewAction = "VIEW_IDENTIFIER"
  static let newsCategory = "NEWS_CATEGORY"
}

@main
struct SpendCraftApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    @StateObject private var authenticator = Authenticator()
    @Environment(\.scenePhase) var scenePhase
    @State var isActive = false
    @State var tabSelection: String = "categories"
    
    func registerForPushNotifications() {
      UNUserNotificationCenter.current()
        .requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
          print("Permission granted: \(granted)")
          guard granted else { return }
          let viewAction = UNNotificationAction(
            identifier: Identifiers.viewAction,
            title: "View",
            options: [.foreground])
          let newsCategory = UNNotificationCategory(
            identifier: Identifiers.newsCategory,
            actions: [viewAction],
            intentIdentifiers: [],
            options: []
          )
          UNUserNotificationCenter.current().setNotificationCategories([newsCategory])
          self.getNotificationSettings()
        }
    }

    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                print("registsering for remote notifications")
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    var opacity: Double {
        scenePhase == .active ? 0 : 1
    }

    var body: some Scene {
        WindowGroup {
            if (authenticator.authenticated) {
                ZStack {
                    MainView(authenticator: authenticator, selection: $tabSelection)
                        .onAppear {
                            registerForPushNotifications()
                        }
                    InactiveView()
                        .opacity(opacity)
                }
                .animation(.easeInOut(duration: 0.25), value: opacity)
            }
            else {
                ZStack {
                    LoginView(authenticator: authenticator)
                    InactiveView()
                        .opacity(opacity)
                }
                .animation(.easeInOut(duration: 0.25), value: opacity)
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
                print("scenePhse unexpected state")
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

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        print( "AppDelegate didFinishLaunchingWithoptions called")
        
        UNUserNotificationCenter.current().delegate = self
        
        // Check if launched from notification
//        let notificationOption = launchOptions?[.remoteNotification]
//
//        // 1
//        if
//            let notification = notificationOption as? [String: AnyObject],
//            let aps = notification["aps"] as? [String: AnyObject] {
//            // 2
//            print("launched by notification")
//
//            // 3
//            //          (window?.rootViewController as? UITabBarController)?.selectedIndex = 1
//        }
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        uploadToken(token: token);
    }
    
    func uploadToken(token: String) {
        struct Data: Encodable {
            var token: String
        }
        
        let data = Data(token: token)

        try? Http.post(path: "/api/user/apns-token", data: data)
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("Failed to register: \(error)")
    }
    
    func application(
      _ application: UIApplication,
      didReceiveRemoteNotification userInfo: [AnyHashable: Any],
      fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
      guard let aps = userInfo["aps"] as? [String: AnyObject] else {
        completionHandler(.failed)
        return
      }
      if aps["content-available"] as? Int == 1 {
//        let podcastStore = PodcastStore.sharedStore
//        podcastStore.refreshItems { didLoadNewItems in
//          completionHandler(didLoadNewItems ? .newData : .noData)
//        }
      } else {
//        NewsItem.makeNewsItem(aps)
//        completionHandler(.newData)
      }
    }}

extension AppDelegate: UNUserNotificationCenterDelegate {
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    print("Did recieve")
//    let userInfo = response.notification.request.content.userInfo

//    if let aps = userInfo["aps"] as? [String: AnyObject],
//      let newsItem = NewsItem.makeNewsItem(aps) {
//      (window?.rootViewController as? UITabBarController)?.selectedIndex = 1
//
//      if response.actionIdentifier == Identifiers.viewAction,
//        let url = URL(string: newsItem.link) {
//        let safari = SFSafariViewController(url: url)
//        window?.rootViewController?.present(safari, animated: true, completion: nil)
//      }
//    }

    completionHandler()
  }
}
