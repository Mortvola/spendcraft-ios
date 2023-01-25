//
//  ForgotPassword.swift
//  SpendCraft
//
//  Created by Richard Shields on 1/17/23.
//

import SwiftUI
import Http

struct ForgotPasswordView: View {
    @State var email = ""
    @State var emailError = ""
    @Binding var path: [NavigationState]
    @Binding var context: Context
    @FocusState private var initialFocus: Bool

    var body: some View {
        VStack {
            VStack(spacing: 16) {
                Text("Enter the email address associated with your account and tap the Continue button.")
            }
            FormFieldView(label: "E-Mail", value: $email, error: emailError)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .textContentType(.emailAddress)
                .focused($initialFocus)
            Button {
                Task {
                    emailError = ""
                    
                    let result = try await Authenticator.shared.requestCode(email: email)

                    if let errors = result.errors {
                        errors.forEach { error in
                            switch(error.field) {
                            case "email":
                                emailError = error.message
                            default:
                                break
                            }
                        }
                    }
                    else {
                        context.email = email
                        context.register = false
                        path.append(.enterCode)
                    }
                }
            } label: {
                Text("Continue")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(email.isEmpty)
            Spacer()
        }
        .padding()
        .navigationTitle("Forgot Password")
        .onAppear {
            initialFocus = true
        }
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView(path: .constant([]), context: .constant(Context()))
    }
}
