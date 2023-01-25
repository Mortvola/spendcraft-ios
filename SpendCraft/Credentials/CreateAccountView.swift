//
//  CreateAccountView.swift
//  SpendCraft
//
//  Created by Richard Shields on 1/13/23.
//

import SwiftUI
import Http

struct CreateAccountView: View {
    @Binding var path: [NavigationState]
    @Binding var context: Context
    @State var username = ""
    @State var usernameError = ""
    @State var email = ""
    @State var emailError = ""
    @State var password = ""
    @State var passwordError = ""
    @State var passwordConfirmation = ""
    @State var passwordConfirmationError = ""
    @ObservedObject var passwordValidator = PasswordValidator()
    @State var passwordValid = false

    var body: some View {
        VStack {
            FormFieldView(label: "Username", value: $username, error: usernameError)
                .disableAutocorrection(true)
                .textContentType(.username)
            FormFieldView(label: "E-Mail", value: $email, error: emailError)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .textContentType(.emailAddress)
            FormFieldView(label: "Password", value: $password, error: passwordError, secured: true)
                .textContentType(.newPassword)
                .onChange(of: password) { newPassword in
                    passwordValid = passwordValidator.validate(password: newPassword)
                }
            FormFieldView(label: "Confirm Password", value: $passwordConfirmation, error: passwordConfirmationError, secured: true)
                .textContentType(.newPassword)
            Button {
                Task {
                    usernameError = ""
                    emailError = ""
                    passwordError = ""
                    passwordConfirmationError = ""
                    
                    struct Data: Encodable {
                        var username: String
                        var email: String
                        var password: String
                        var passwordConfirmation: String
                    }

                    let data = Data(
                        username: username,
                        email: email,
                        password: password,
                        passwordConfirmation: passwordConfirmation
                    )

                    let result = try await Http.post(path: "/api/register", data: data)

                    if let errors = result.errors {
                        errors.forEach { error in
                            switch(error.field) {
                            case "username":
                                usernameError = error.message
                            case "email":
                                emailError = error.message
                            case "password":
                                passwordError = error.message
                            case "passwordConfirmation":
                                passwordConfirmationError = error.message
                            default:
                                break
                            }
                        }
                    }
                    else {
                        context.email = email
                        context.register = true
                        Authenticator.shared.savePassword(password)
                        path.append(.enterCode)
                    }
                }
            } label: {
                Text("Create Account")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(
                username.isEmpty ||
                email.isEmpty ||
                !passwordValid ||
                password != passwordConfirmation)
            PasswordRulesView(passwordValidator: passwordValidator)
                .padding(.top, 16)
            Spacer()
        }
        .padding()
        .navigationTitle("Create Account")
    }
}

struct CreateAccountView_Previews: PreviewProvider {
    static var previews: some View {
        CreateAccountView(path: .constant([]), context: .constant(Context()))
    }
}
