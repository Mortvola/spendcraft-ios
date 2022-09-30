//
//  LoginView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/16/22.
//

import SwiftUI
import LocalAuthentication

struct LoginView: View {
    @Binding var authenticated: Bool
    @State var username = ""
    @State var password = ""
    let server = "spendcraft.app"
    
    /// Keychain errors we might encounter.
    struct KeychainError: Error {
        var status: OSStatus

        var localizedDescription: String {
            return SecCopyErrorMessageString(status, nil) as String? ?? "Unknown error."
        }
    }
    
    func authenticate() {
        Authentication.signIn(username: username, password: password) { result in
            switch result {
            case .failure(let error):
                fatalError(error.localizedDescription)
            case .success(let authenticated):
                self.authenticated = authenticated
                do {
                    try addCredentials(username: username, password: password)
                }
                catch {
                }
            }
        }
    }

    func addCredentials(username: String, password: String) throws {
        // Create an access control instance that dictates how the item can be read later.
        let access = SecAccessControlCreateWithFlags(nil, // Use the default allocator.
                                                     kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
                                                     .userPresence,
                                                     nil) // Ignore any error.

        // Allow a device unlock in the last 10 seconds to be used to get at keychain items.
        let context = LAContext()
        context.touchIDAuthenticationAllowableReuseDuration = 10

        // Build the query for use in the add operation.
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrAccount as String: username,
                                    kSecAttrServer as String: server,
                                    kSecAttrAccessControl as String: access as Any,
                                    kSecUseAuthenticationContext as String: context,
                                    kSecValueData as String: password.data(using: String.Encoding.utf8)!]

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError(status: status) }
    }

    func getCredentials() throws {
        let context = LAContext()
        context.localizedReason = "Access your password on the keychain"
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrServer as String: server,
                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                    kSecReturnAttributes as String: true,
                                    kSecUseAuthenticationContext as String: context,
                                    kSecReturnData as String: true]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else {
            print("keychain error: \(SecCopyErrorMessageString(status, nil) as String? ?? "Unknown error.")")
            throw KeychainError(status: status)
        }

        guard let existingItem = item as? [String: Any],
            let passwordData = existingItem[kSecValueData as String] as? Data,
            let password = String(data: passwordData, encoding: String.Encoding.utf8),
            let account = existingItem[kSecAttrAccount as String] as? String
            else {
                throw KeychainError(status: errSecInternalError)
        }
        
        self.username = account
        self.password = password
        
        print("account: \(account), password: \(password)")
        authenticate()
    }

    var body: some View {
        VStack {
            TextField("Username", text: $username)
            HStack {
                SecureField("Password", text: $password)
                Button(action: {
                    do {
                        try getCredentials()
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
        }
        .padding(.horizontal)
        .onAppear() {
            do {
                try getCredentials()
            }
            catch {
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var authenticated = false;

    static var previews: some View {
        LoginView(authenticated: .constant(authenticated))
    }
}
