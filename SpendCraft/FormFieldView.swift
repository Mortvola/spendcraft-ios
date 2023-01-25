//
//  FormFieldView.swift
//  SpendCraft
//
//  Created by Richard Shields on 1/14/23.
//

import SwiftUI
import Combine

struct FormFieldView: View {
    var label: String
    @Binding var value: String
    var error = ""
    var secured = false
    var textLimit: Int? = nil

    func limitText(_ max: Int?) {
        if let max = max {
            if value.count > max {
                value = String(value.prefix(max))
            }
        }
    }

    var body: some View {
        VStack {
            if secured {
                SecureField(label, text: $value)
                    .onReceive(Just(value)) { _ in limitText(textLimit) }
            }
            else {
                TextField(label, text: $value)
                    .onReceive(Just(value)) { _ in limitText(textLimit) }
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
