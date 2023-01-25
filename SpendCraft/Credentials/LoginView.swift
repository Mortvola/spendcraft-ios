//
//  LoginView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/16/22.
//

import SwiftUI
import LocalAuthentication

enum NavigationState {
    case enterEmail
    case enterCode
    case setPassword
    case register
}

struct Context {
    var email: String = ""
    var register = false
}

struct LoginView: View {
    @ObservedObject var authenticator = Authenticator.shared
    @StateObject private var navModel = NavModel.shared
    @Environment(\.scenePhase) var scenePhase
    @State var isActive = false
    @State var username = ""
    @State var password = ""
    @State var isRegistering = false
//    @State var showForgotPassword = false
    @State var usernameError = ""
    @State var passwordError = ""
    @State var presentedPath: [NavigationState] = []
    @State var context = Context()
    @State var showCredentials = false
    @State var credentials: [Creds] = []
    @State var credentialSelection: Int = -1

    func authenticate() async {
        let errors = await authenticator.signIn(username: username, password: password)
        
        if let errors = errors {
            errors.forEach { error in
                switch(error.field) {
                case "username":
                    usernameError = error.message
                case "password":
                    passwordError = error.message
                default:
                    break
                }
            }
        }
    }

    var body: some View {
        NavigationStack(path: $presentedPath) {
            VStack {
                Spacer()
                    .frame(maxHeight: 64)
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
                        FormFieldView(label: "Username", value: $username, error: usernameError)
                            .textContentType(.username)
                        HStack {
                            FormFieldView(label: "Password", value: $password, error: passwordError, secured: true)
                                .textContentType(.password)
                            Button(action: {
                                do {
                                    credentials = try authenticator.getCredentials()
                                    
                                    if credentials.count > 1 {
                                        showCredentials = true
                                    }
                                    else if credentials.count == 1 && !credentials[0].username.isEmpty && !credentials[0].password.isEmpty {
                                        username = credentials[0].username
                                        password = credentials[0].password
                                        Task {
                                            await authenticate()
                                        }
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
                        NavigationLink("Forgot my password", value: NavigationState.enterEmail)
                        Spacer()
                    }
                    HStack {
                        NavigationLink("Create Account", value: NavigationState.register)
                        Spacer()
                    }
                }
                Spacer()
            }
            .padding(.horizontal)
            .navigationDestination(for: NavigationState.self) { state in
                switch (state) {
                case .enterEmail:
                    ForgotPasswordView(path: $presentedPath, context: $context)
                case .enterCode:
                    EnterPassCodeView(path: $presentedPath, context: $context)
                case .setPassword:
                    EnterPasswordView(path: $presentedPath)
                case .register:
                    CreateAccountView(path: $presentedPath, context: $context)
                }
            }
            .sheet(isPresented: $showCredentials) {
                CredentialListView(show: $showCredentials, credentials: $credentials, selection: $credentialSelection)
                    .presentationDetents([.medium])
            }
            .onChange(of: credentialSelection) { sel in
                username = credentials[sel].username
                password = credentials[sel].password
                Task {
                    await authenticate()
                }
            }
            .onChange(of: scenePhase) { phase in
                switch phase {
                case .active:
                    self.isActive = true
                case .inactive:
                    if !self.isActive {
                        // Activating...
                        if !authenticator.authenticated {
                            // Transitioning from background to active state, attempt signIn
                            credentials = (try? authenticator.getCredentials()) ?? []
                            
                            if credentials.count > 1 {
                                showCredentials = true
                            }
                            else if credentials.count == 1 && !credentials[0].username.isEmpty && !credentials[0].password.isEmpty {
                                username = credentials[0].username
                                password = credentials[0].password
                                Task {
                                    await authenticate()
                                    navModel.tabSelection = .categories
                                }
                            }
                        }
                    }
                case .background:
                    self.isActive = false
                @unknown default:
                    print("scenePhase unexpected state")
                }
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
