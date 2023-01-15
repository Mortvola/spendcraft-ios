//
//  CreateAccountView.swift
//  SpendCraft
//
//  Created by Richard Shields on 1/13/23.
//

import SwiftUI
import Http

struct CreateAccountView: View {
    @State var username = ""
    @State var usernameError = ""
    @State var email = ""
    @State var emailError = ""
    @State var password = ""
    @State var passwordError = ""
    @State var passwordConfirmation = ""
    @State var passwordConfirmationError = ""
    @Binding var show: Bool

    var body: some View {
        NavigationStack {
            VStack {
                FormFieldView(label: "Username", value: $username, error: usernameError)
                FormFieldView(label: "E-Mail", value: $email, error: emailError)
                FormFieldView(label: "Password", value: $password, error: passwordError, secured: true)
                FormFieldView(label: "Confirm Password", value: $passwordConfirmation, error: passwordConfirmationError, secured: true)
                Button {
                    Task {
                        struct Data: Encodable {
                            var username: String
                            var email: String
                            var password: String
                            var password_confirmation: String
                        }

                        let data = Data(
                            username: username,
                            email: email,
                            password: password,
                            password_confirmation: passwordConfirmation
                        )

                        let result = try await Http.post(path: "/register", data: data)

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
                            show = false
                        }
                    }
                } label: {
                    Text("Create Account")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(username.isEmpty || password.isEmpty || passwordConfirmation.isEmpty || email.isEmpty)
                Spacer()
            }
            .padding()
            .navigationTitle("Create Account")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        show = false
                    }
                }
            }
        }
    }
}

struct CreateAccountView_Previews: PreviewProvider {
    static var previews: some View {
        CreateAccountView(show: .constant(true))
    }
}
