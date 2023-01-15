//
//  SettingsView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/30/22.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var authenticator: Authenticator
    let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
    @State var isInvitingCollaborator = false
    
    var body: some View {
        Form {
            LabeledContent("Version") {
                if let version = version {
                    Text(version)
                } else {
                    Text("Unknown")
                }
            }
            ControlGroup {
                LabeledContent("Username") {
                    Text(authenticator.username)
                }
                NavigationLink(destination: ChangePasswordView()) {
                    Text("Reset Password")
                }
            }
            ControlGroup {
                Button(action: {
                    authenticator.authenticated = false
                }) {
                    HStack {
                        Spacer()
                        Text("Sign Out")
                        Spacer()
                    }
                }
            }
            ControlGroup {
                Button(action: {
                    isInvitingCollaborator = true
                }) {
                    HStack {
                        Spacer()
                        Text("Invite Collaborator")
                        Spacer()
                    }
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static let authentication = Authenticator()
    
    static var previews: some View {
        SettingsView(authenticator: authentication)
    }
}
