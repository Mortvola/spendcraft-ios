//
//  SettingsView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/30/22.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var authentication: Authentication

    var body: some View {
        Button(action: {
            authentication.authenticated = false
        }) {
            Text("Sign Out")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static let authentication = Authentication()
    
    static var previews: some View {
        SettingsView(authentication: authentication)
    }
}
