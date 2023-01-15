//
//  FormFieldView.swift
//  SpendCraft
//
//  Created by Richard Shields on 1/14/23.
//

import SwiftUI

struct FormFieldView: View {
    var label: String
    @Binding var value: String
    var error = ""
    var secured = false

    var body: some View {
        VStack {
            if secured {
                SecureField(label, text: $value)
            }
            else {
                TextField(label, text: $value)
            }
            FieldErrorView(error: error)
        }
    }
}

struct FormFieldView_Previews: PreviewProvider {
    static var value = ""

    static var previews: some View {
        FormFieldView(label: "Test", value: .constant(value))
    }
}
