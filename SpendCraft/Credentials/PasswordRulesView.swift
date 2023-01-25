//
//  PasswordRulesView.swift
//  SpendCraft
//
//  Created by Richard Shields on 1/23/23.
//

import SwiftUI

struct PasswordRulesView: View {
    @ObservedObject var passwordValidator: PasswordValidator
    
    var body: some View {
        VStack {
            HStack {
                Text("Password Requirements:")
                Spacer()
            }
            PasswordRuleView(label: "Minimum of 8 characters", met: passwordValidator.minimum)
            PasswordRuleView(label: "At least one uppercase letter", met: passwordValidator.upper)
            PasswordRuleView(label: "At least one lowercase letter", met: passwordValidator.lower)
            PasswordRuleView(label: "At least one digit", met: passwordValidator.digit)
        }
    }
}

struct PasswordRulesView_Previews: PreviewProvider {
    static var passwordValidator = PasswordValidator()
    
    static var previews: some View {
        PasswordRulesView(passwordValidator: passwordValidator)
    }
}
