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

    let transactions: [Transaction] = [
        try! Transaction(date: "2022-12-16", name: "Costco", amount: 300.0, institution: "Citi", account: "Checking"),
        try! Transaction(date: "2022-11-15", name: "Safeway", amount: 250.0, institution: "Citi", account: "Checking")
    ]

    var body: some Scene {
        WindowGroup {
            if (authentication.authenticated) {
                RegisterView(transactions: transactions)
            }
            else {
                LoginView(authenticated: $authentication.authenticated)
            }
        }
    }
}
