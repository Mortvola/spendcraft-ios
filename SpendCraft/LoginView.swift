//
//  LoginView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/16/22.
//

import SwiftUI
import LocalAuthentication

struct LoginView: View {
    @ObservedObject var authenticator: Authenticator
    @State var username = ""
    @State var password = ""
    
    func authenticate() {
        authenticator.signIn(username: username, password: password)
    }

    var body: some View {
        VStack {
            Spacer()
                .frame(maxHeight: 128)
            HStack {
                Image(uiImage: UIImage(named: "Logo") ?? UIImage())
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                Text("SpendCraft")
                    .font(.largeTitle)
            }
            .frame(maxHeight: 64)
            Spacer()
                .frame(maxHeight: 64)
            TextField("Username", text: $username)
            HStack {
                SecureField("Password", text: $password)
                Button(action: {
                    do {
                        (username, password) = try Authenticator.getCredentials()
                        authenticate()
                    }
                    catch {
                    }
                }) {
                    Image(systemName: "faceid")
                }
            }
            Button(action: {
                authenticate()
            }) {
                Text("Sign In")
            }
            .disabled(username.isEmpty || password.isEmpty)
            Spacer()
        }
        .padding(.horizontal)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var authenticator = Authenticator()

    static var previews: some View {
        LoginView(authenticator: authenticator)
    }
}
