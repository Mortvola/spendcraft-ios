//
//  NumericField.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/20/22.
//

import SwiftUI
import Combine

public extension String {
    func numericValue() -> String {
        var hasFoundDecimal = false
        var index = 0
        return self.filter {
            if $0.isWholeNumber {
                defer { index += 1}
                return true
            }

            if $0 == "-" {
                defer { index += 1}
                return index == 0
            }
            
            if String($0) == (Locale.current.decimalSeparator ?? ".") {
                defer { hasFoundDecimal = true; index += 1 }
                return !hasFoundDecimal
            }
            
            return false
        }
    }
}

struct NumericField: View {
    @State private var valueString: String = ""
    @Binding private var value: Double?
    private let formatter: NumberFormatter = NumberFormatter()
    @FocusState private var isFocused: Bool

    init(value: Binding<Double?>) {
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        
        _value = value
        if let value = value.wrappedValue, let string = formatter.string(from: NSNumber(value: value)) {
            _valueString = State(initialValue: string)
        } else {
            _valueString = State(initialValue: "")
        }
    }

    private func numberChanged(newValue: String) {
        let numeric = newValue.numericValue()
        if newValue != numeric {
            valueString = numeric
        }
        value = formatter.number(from: valueString)?.doubleValue
    }

    var body: some View {
        TextField("Amount", text: $valueString)
            .onChange(of: valueString, perform: numberChanged(newValue:))
            .focused($isFocused)
            .onChange(of: isFocused) { isFocused in
                if (!isFocused) {
                    if let value = value, let string = formatter.string(from: NSNumber(value: value)) {
                        valueString = string
                    }
                }
            }
            .multilineTextAlignment(.trailing)
            .keyboardType(.numbersAndPunctuation)
            .foregroundColor((value ?? 0) < 0 ? Color(.red) : nil)
    }
}

struct NumericField_Previews: PreviewProvider {
    static let value: Double? = 100.0

    static var previews: some View {
        NumericField(value: .constant(value))
    }
}
