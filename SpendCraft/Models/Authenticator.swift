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

struct Creds: Identifiable {
    var id: String { username }
    
    var username: String
    var password: String
}

class Authenticator: ObservableObject {
    @Published var authenticated = false
    @Published var username = ""
    var context: LAContext? = nil
    
    static var shared = Authenticator()

    /// Keychain errors we might encounter.
    struct KeychainError: Error {
        var status: OSStatus
        
        var localizedDescription: String {
            return SecCopyErrorMessageString(status, nil) as String? ?? "Unknown error."
        }
    }
    
    @MainActor
    func signIn(username: String, password: String) async -> Errors? {
        struct Data: Encodable {
            var username: String
            var password: String
        }
        
        Busy.shared.start()
        
        let data = Data(username: username, password: password)

        do {
            // Make sure the access and refresh tokens are not set
            Http.setTokens("", "")
            
            let response: Http.Response<Response.Login> = try await Http.post(path: "/api/login", data: data)
            
            if let errors = response.errors {
                Busy.shared.stop()
                return errors
            }

            self.username = username
            savePassword(password)
        
            self.setAuthenticated()
            
            if let data = response.data {
                Http.setTokens(data.access, data.refresh)
            }
        }
        catch {
            print(error)
        }
        
        Busy.shared.stop()
        
        return nil
    }
    
    func savePassword(_ password: String) {
        try? self.addCredentials(username: username, password: password)
    }
    
    @MainActor
    func signOut() async {
        Busy.shared.start()

        do {
            struct LogoutRequest: Encodable {
                struct Data: Encodable {
                    var refresh: String
                }
                
                init(refreshToken: String) {
                    self.data = Data(refresh: refreshToken)
                }
                
                var data: Data
            }
            
            let logoutRequest = LogoutRequest(refreshToken: Http.getRefreshToken())
            
            try await Http.post(path: "/api/logout", data: logoutRequest)
            
            Http.setTokens("", "")
            self.context = nil
        }
        catch {
            print(error)
        }

        self.setUnauthenticated()

        Busy.shared.stop()
    }
    
    @MainActor
    func setAuthenticated() {
        self.authenticated = true
    }

    @MainActor
    func setUnauthenticated() {
        self.authenticated = false
    }

    func requestCode(email: String) async throws -> Http.EmptyResponse {
        struct Data: Encodable {
            var email: String
        }

        let data = Data(
            email: email
        )

        return try await Http.post(path: "/api/code-request", data: data)
    }

    func addCredentials(username: String, password: String) throws {
        if self.context == nil {
            self.context = LAContext()
        }
    
        if let context = self.context {
            // Item exists so update it
            
            let encodedPassword = password.data(using: String.Encoding.utf8)!
            
            // Build the query for use in the add operation.
            let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                        kSecAttrServer as String: Http.serverName,
                                        kSecAttrAccount as String: username,
                                        kSecUseAuthenticationContext as String: context]
            
            let attributesToUpdate:  [String : Any] = [
                kSecValueData as String: encodedPassword as Any
            ]
            
            var status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
            
            if status == errSecItemNotFound {
                // The item was not found so add it.
                
                // Create an access control instance that dictates how the item can be read later.
                let access = SecAccessControlCreateWithFlags(nil, // Use the default allocator.
                                                             kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
                                                             .userPresence,
                                                             nil) // Ignore any error.
                
                // Allow a device unlock in the last 10 seconds to be used to get at keychain items.
                context.touchIDAuthenticationAllowableReuseDuration = 10
                
                // Build the query for use in the add operation.
                let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                            kSecAttrAccount as String: username,
                                            kSecAttrServer as String: Http.serverName,
                                            kSecAttrAccessControl as String: access as Any,
                                            kSecUseAuthenticationContext as String: context,
                                            kSecValueData as String: encodedPassword]
                
                status = SecItemAdd(query as CFDictionary, nil)
            }
            
            // Throw an error if an unexpected status was returned.
            guard status == errSecSuccess else {
                print("keychain error: \(SecCopyErrorMessageString(status, nil) as String? ?? "Unknown error.")")
                throw KeychainError(status: status)
            }
        }
    }
    
    func getCredentials() throws -> [Creds] {
        if self.context == nil {
            self.context = LAContext()
        }
    
        if let context = self.context {
            let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                        kSecAttrServer as String: Http.serverName,
                                        kSecMatchLimit as String: kSecMatchLimitAll,
                                        kSecReturnAttributes as String: true,
                                        kSecUseAuthenticationContext as String: context,
                                        kSecReturnRef as String: true]
            
            var items: CFTypeRef?
            let status = SecItemCopyMatching(query as CFDictionary, &items)
            
            guard status == errSecSuccess else {
                print("keychain error: \(SecCopyErrorMessageString(status, nil) as String? ?? "Unknown error.")")
                throw KeychainError(status: status)
            }
            
            let array = items as! [NSDictionary]
            
            var credentials = array.compactMap { item in
                if let username = item[kSecAttrAccount as String] as? String {
                    let passwordData = item[kSecValueData as String] as! Data
                    let password = String(data: passwordData, encoding: .utf8)
                    return Creds(username: username, password: password ?? "")
                }
                
                return nil
            }
            
            credentials = credentials.sorted {
                $0.username < $1.username
            }
            
            return credentials
        }
        
        return []
    }
}
