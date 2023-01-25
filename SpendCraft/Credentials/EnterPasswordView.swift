//
//  EnterPasswordView.swift
//  SpendCraft
//
//  Created by Richard Shields on 1/18/23.
//

import SwiftUI
import Http

struct EnterPasswordView: View {
    @Binding var path: [NavigationState]
    @State var password = ""
    @State var passwordConfirmation = ""
    @State var passwordError = ""
    @State var passwordConfirmationError = ""
    let passwordMinimum = 8
    let passwordMaximum = 64
    @FocusState private var initialFocus: Bool
    @ObservedObject var passwordValidator = PasswordValidator()
    @State var passwordValid = false
    
    var body: some View {
        VStack {
            FormFieldView(label: "Password", value: $password, error: passwordError, secured: true, textLimit: passwordMaximum)
                .textContentType(.newPassword)
                .focused($initialFocus)
                .onChange(of: password) { newPassword in
                    passwordValid = passwordValidator.validate(password: newPassword)
                }
            FormFieldView(label: "Confirm Password", value: $passwordConfirmation, error: passwordConfirmationError, secured: true, textLimit: passwordMaximum)
                .textContentType(.newPassword)
            Button {
                Task {
                    passwordError = ""
                    passwordConfirmationError = ""
                    
                    struct Data: Encodable {
                        var password: String
                        var passwordConfirmation: String
                    }

                    let data = Data(
                        password: password,
                        passwordConfirmation: passwordConfirmation
                    )

                    let result = try await Http.post(path: "/api/password/update", data: data)

                    if let errors = result.errors {
                        errors.forEach { error in
                            switch(error.field) {
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
                        Authenticator.shared.savePassword(password)
                        Authenticator.shared.setAuthenticated()
                        path = []
                    }
                }
            } label: {
                Text("Change Password")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(
                !passwordValid ||
                passwordConfirmation != password
            )
            PasswordRulesView(passwordValidator: passwordValidator)
                .padding(.top, 16)
            Spacer()
        }
        .padding()
        .navigationTitle("Enter New Password")
        .onAppear {
            initialFocus = true
        }
    }
}

struct EnterPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        EnterPasswordView(path: .constant([]))
    }
}
