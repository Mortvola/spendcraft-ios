//
//  LoginView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/16/22.
//

import SwiftUI

struct LoginView: View {
    @Binding var authenticated: Bool
    @State var username = ""
    @State var password = ""

    var body: some View {
        VStack {
            TextField("Username", text: $username)
            SecureField("Password", text: $password)
            Button(action: {
                Authentication.signIn(username: username, password: password) { result in
                    switch result {
                    case .failure(let error):
                        fatalError(error.localizedDescription)
                    case .success(let authenticated):
                        self.authenticated = authenticated
                    }
                }
            }) {
                Text("Sign In")
            }
        }
        .padding(.horizontal)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var authenticated = false;

    static var previews: some View {
        LoginView(authenticated: .constant(authenticated))
    }
}
