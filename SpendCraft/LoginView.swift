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
    @State var isRegistering = false
    
    func authenticate() async {
        await authenticator.signIn(username: username, password: password)
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
            VStack(spacing: 16) {
                VStack(spacing: 8) {
                    TextField("Username", text: $username)
                    HStack {
                        SecureField("Password", text: $password)
                        Button(action: {
                            do {
                                (username, password) = try authenticator.getCredentials()
                                Task {
                                    await authenticate()
                                }
                            }
                            catch {
                            }
                        }) {
                            Image(systemName: "faceid")
                        }
                    }
                }
                Button {
                    Task {
                        await authenticate()
                    }
                } label: {
                    Text("Sign In")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(username.isEmpty || password.isEmpty)
            }
            Spacer().frame(height:32)
            VStack(spacing: 16) {
                HStack {
                    Button {
                        isRegistering = true
                    } label: {
                        Text("Forgot my password")
                    }
                    Spacer()
                }
                HStack {
                    Button {
                        isRegistering = true
                    } label: {
                        Text("Create Account")
                    }
                    Spacer()
                }
            }
            Spacer()
        }
        .padding(.horizontal)
        .sheet(isPresented: $isRegistering) {
            CreateAccountView(show: $isRegistering)
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var authenticator = Authenticator()

    static var previews: some View {
        LoginView(authenticator: authenticator)
    }
}
