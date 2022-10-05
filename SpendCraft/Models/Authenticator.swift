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
    static let server = "spendcraft.app"
    
    /// Keychain errors we might encounter.
    struct KeychainError: Error {
        var status: OSStatus
        
        var localizedDescription: String {
            return SecCopyErrorMessageString(status, nil) as String? ?? "Unknown error."
        }
    }
    
    func signIn(username: String, password: String) {
        guard let url = URL(string: "https://spendcraft.app/login") else {
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let session = try? getSession() else {
            return
        }
        
        struct Data: Encodable {
            var username: String
            var password: String
            var remember: String
        }
        
        let data = Data(username: username, password: password, remember: "on")
        
        guard let uploadData = try? JSONEncoder().encode(data) else {
            return
        }
        
        let task = session.uploadTask(with: urlRequest, from: uploadData) {data, response, error in
            if let error = error {
                print("Error: \(error)");
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                print ("response is nil")
                return
            }
            
            guard (200...299).contains(response.statusCode) else {
                print ("Server error: \(response.statusCode)")
                return
            }

            do {
                try Authenticator.addCredentials(username: username, password: password)
            }
            catch {
            }

            print("success: \(response.statusCode)")
            DispatchQueue.main.async {
                self.authenticated = true
            }
        }
        task.resume()
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
                                    kSecAttrServer as String: server,
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
            let username = existingItem[kSecAttrAccount as String] as? String
            else {
                throw KeychainError(status: errSecInternalError)
        }
        
        return (username, password)
    }
}