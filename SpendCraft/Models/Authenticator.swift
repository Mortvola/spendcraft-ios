//
//  Authentication.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/18/22.
//

import Foundation
import LocalAuthentication

class Authenticator: ObservableObject {
    @Published var authenticated = false
    
    /// Keychain errors we might encounter.
    struct KeychainError: Error {
        var status: OSStatus
        
        var localizedDescription: String {
            return SecCopyErrorMessageString(status, nil) as String? ?? "Unknown error."
        }
    }
    
    func signIn(username: String, password: String) {
        struct Data: Encodable {
            var username: String
            var password: String
            var remember: String
        }
        
        let data = Data(username: username, password: password, remember: "on")

        try? Http.post(path: "/login", data: data) { _ in
            try? Authenticator.addCredentials(username: username, password: password)

            DispatchQueue.main.async {
                self.authenticated = true
            }
        }
    }
    
    static func addCredentials(username: String, password: String) throws {
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
                                    kSecAttrServer as String: serverName,
                                    kSecAttrAccessControl as String: access as Any,
                                    kSecUseAuthenticationContext as String: context,
                                    kSecValueData as String: password.data(using: String.Encoding.utf8)!]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError(status: status) }
    }
    
    static func getCredentials() throws -> (username: String, password: String) {
        let context = LAContext()
        context.localizedReason = "Access your password on the keychain"
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrServer as String: serverName,
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
            let username = existingItem[kSecAttrAccount as String] as? String
            else {
                throw KeychainError(status: errSecInternalError)
        }
        
        return (username, password)
    }
}
