//
//  NumericField.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/20/22.
//

import SwiftUI
import Combine

struct NumericField: View {
    @State private var enteredValue: String = ""
    @Binding var value: Double
    @FocusState private var isFocused: Bool

    var body: some View {
        TextField("Amount", text: $enteredValue)
            .onReceive(Just(enteredValue)) { typedValue in
                if let newValue = Double(typedValue) {
                    if (value != newValue) {
                        value = newValue
                    }
                }
                else {
                    let filtered = typedValue.filter {
                        $0.isNumber || $0 == "." || $0 == "-"
                    }

                    if (enteredValue != filtered) {
                        enteredValue = filtered
                    }
                }
            }
            .focused($isFocused)
            .onChange(of: isFocused) { isFocused in
                if (!isFocused) {
                    enteredValue = String(format: "%.2f", value)
                }
            }
            .onAppear {
                enteredValue = String(format: "%.2f", value)
            }
            .multilineTextAlignment(.trailing)
            .keyboardType(.numbersAndPunctuation)
            .foregroundColor(value < 0 ? Color(.red) : nil)
    }
}

struct NumericField_Previews: PreviewProvider {
    static let value: Double = 0

    static var previews: some View {
        NumericField(value: .constant(value))
    }
}
