//
//  PasswordCodeView.swift
//  SpendCraft
//
//  Created by Richard Shields on 1/18/23.
//

import SwiftUI
import Combine
import Http

struct EnterPassCodeView: View {
    @State var code: String = ""
    @State var codeError: String = ""
    @State var codeSent: String = ""
    @Binding var path: [NavigationState]
    @Binding var context: Context
    let textLimit = 9
    @FocusState private var initialFocus: Bool

    var body: some View {
        VStack {
            Text("We sent a code to the email address you provided. Enter the code below and tap the Verify Code button.")
            FormFieldView(label: "Code", value: $code, error: codeError, textLimit: textLimit)
                .textInputAutocapitalization(.never)
                .focused($initialFocus)
            Button {
                codeError = ""
                
                Task {
                    struct Data: Encodable {
                        var email: String
                        var code: String
                    }

                    let data = Data(
                        email: context.email,
                        code: code
                    )

                    let response: Http.Response<Response.PassCodeVerify> = try await Http.post(path: "/api/code-verify", data: data)

                    if let errors = response.errors {
                        errors.forEach { error in
                            switch(error.field) {
                            case "code":
                                codeError = error.message
                            default:
                                break
                            }
                        }
                    }
                    else {
                        if let data = response.data {
                            Http.setTokens(data.access, data.refresh)
                            Authenticator.shared.username = data.username
                        }

                        if context.register {
                            Authenticator.shared.setAuthenticated()
                            path = []
                        } else {
                            path.append(.setPassword)
                        }
                    }
                }
            } label: {
                Text("Verify Code")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(code.count != textLimit)
            Text("If you did not receive a code or if the code you received has expired you may request a new code by tapping the button below.")
            Button {
                codeSent = ""
                code = ""
                codeError = ""
                
                Task {
                    let result = try await Authenticator.shared.requestCode(email: context.email)
                    
                    if let errors = result.errors {
                        errors.forEach { error in
                            switch(error.field) {
                            case "email":
                                // emailError = error.message
                                break;
                            default:
                                break
                            }
                        }
                    }
                    else {
                        codeSent = "A new code has been sent."
                    }
                }
            } label: {
                Text("Send New Code")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            HStack {
                Text(codeSent)
                Spacer()
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Enter Code")
        .onAppear {
            initialFocus = true
        }
    }
}

struct EnterPassCodeView_Previews: PreviewProvider {
    static var previews: some View {
        EnterPassCodeView(path: .constant([]), context: .constant(Context()))
    }
}
