//
//  Authentication.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/18/22.
//

import Foundation
import LocalAuthentication
import Framework
import Http

class Authenticator: ObservableObject {
    @Published var authenticated = false
    @Published var username = ""
    
    /// Keychain errors we might encounter.
    struct KeychainError: Error {
        var status: OSStatus
        
        var localizedDescription: String {
            return SecCopyErrorMessageString(status, nil) as String? ?? "Unknown error."
        }
    }
    
    @MainActor
    func signIn(username: String, password: String) async {
        struct Data: Encodable {
            var username: String
            var password: String
            var remember: String
        }
        
        Busy.shared.start()
        
        let data = Data(username: username, password: password, remember: "on")

        do {
            let response: Http.Response<Response.Login> = try await Http.post(path: "/api/login", data: data)
            
            if let errors = response.errors {
                // todo: handle errors
            } else {
                try? self.addCredentials(username: username, password: password)
                
                self.authenticated = true
                self.username = username
                
                if let data = response.data {
                    Http.setToken(data)
                }
            }
        }
        catch {
            print(error)
        }
        
        Busy.shared.stop()
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
                                    kSecAttrServer as String: Http.serverName,
                                    kSecAttrAccessControl as String: access as Any,
                                    kSecUseAuthenticationContext as String: context,
                                    kSecValueData as String: password.data(using: String.Encoding.utf8)!]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError(status: status) }
    }
    
    func getCredentials() throws -> (username: String, password: String) {
        let context = LAContext()
        context.localizedReason = "Access your password on the keychain"
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrServer as String: Http.serverName,
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
