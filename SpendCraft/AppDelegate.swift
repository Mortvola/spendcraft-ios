//
//  AppDelegate.swift
//  SpendCraft
//
//  Created by Richard Shields on 10/13/22.
//

import Foundation
import SwiftUI
import Framework
import Http

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        
        Http.setServer(serverName: "https://spendcraft.app")
//        Http.setServer(serverName: "https://sandbox.spendcraft.app:3334")

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
        Task {
            await uploadToken(token: token);
        }
    }
    
    func uploadToken(token: String) async {
        struct Data: Encodable {
            var token: String
        }
        
        let data = Data(token: token)

        try? await Http.post(path: "/api/user/apns-token", data: data)
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("Failed to register: \(error)")
    }

    /*
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
    }
    */
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
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

        Task {
            NavModel.shared.tabSelection = TabSelection.categories
            NavModel.shared.selectedCategory = CategoriesStore.shared.unassigned
            NavModel.shared.transactionState = TransactionState.Posted
            await TransactionStore.shared.loadTransactions(category: CategoriesStore.shared.unassigned, transactionState: TransactionState.Posted, clear: true)
        }

        completionHandler()
    }
}
