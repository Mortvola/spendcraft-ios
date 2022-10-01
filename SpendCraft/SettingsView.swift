//
//  SettingsView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/30/22.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var authenticator: Authenticator

    var body: some View {
        Button(action: {
            authenticator.authenticated = false
        }) {
            Text("Sign Out")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static let authentication = Authenticator()
    
    static var previews: some View {
        SettingsView(authenticator: authentication)
    }
}
