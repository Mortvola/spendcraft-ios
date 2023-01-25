//
//  PasswordRuleView.swift
//  SpendCraft
//
//  Created by Richard Shields on 1/23/23.
//

import SwiftUI

struct PasswordRuleView: View {
    var label: String
    var met: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "checkmark")
                .opacity(met ? 1: 0)
            Text(label)
            Spacer()
        }
    }
}

struct PasswordRuleView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordRuleView(label: "A test rule", met: true)
    }
}
