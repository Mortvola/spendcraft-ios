//
//  PasswordValidator.swift
//  SpendCraft
//
//  Created by Richard Shields on 1/23/23.
//

import Foundation

class PasswordValidator: ObservableObject {
    @Published var minimum = false
    @Published var upper = false
    @Published var lower = false
    @Published var digit = false

    private var minimumRule = /(?=.{8,})/
    private var upperRule = /(?=.*?[A-Z])/
    private var lowerRule = /(?=.*?[a-z])/
    private var digitRule = /(?=.*?[0-9])/

    func validate(password: String) -> Bool {
        self.minimum = (try? minimumRule.firstMatch(in: password)) != nil
        self.upper = (try? upperRule.firstMatch(in: password)) != nil
        self.lower = (try? lowerRule.firstMatch(in: password)) != nil
        self.digit = (try? digitRule.firstMatch(in: password)) != nil
        
        return self.minimum && self.upper && self.lower && self.digit
    }
}
