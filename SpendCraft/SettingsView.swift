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
    @State var presentedPath: [NavigationState] = []

    var body: some View {
        NavigationStack(path: $presentedPath) {
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
                    NavigationLink("Change Password", value: NavigationState.setPassword)
                }
                ControlGroup {
                    Button(action: {
                        Task {
                            await authenticator.signOut()
                        }
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
            .navigationDestination(for: NavigationState.self) { state in
                if state == .setPassword {
                    EnterPasswordView(path: $presentedPath)
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
