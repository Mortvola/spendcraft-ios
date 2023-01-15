//
//  FieldErrorView.swift
//  SpendCraft
//
//  Created by Richard Shields on 1/14/23.
//

import SwiftUI

struct FieldErrorView: View {
    var error = ""

    var body: some View {
        HStack {
            Text(error).foregroundColor(.red)
            Spacer()
        }
    }
}

struct FieldErrorView_Previews: PreviewProvider {
    static var previews: some View {
        FieldErrorView()
    }
}
