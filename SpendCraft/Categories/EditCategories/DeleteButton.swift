//
//  DeleteButton.swift
//  SpendCraft
//
//  Created by Richard Shields on 10/12/22.
//

import SwiftUI

struct DeleteButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Spacer()
                Text("Delete")
                    .foregroundColor(Color(uiColor: .red))
                Spacer()
            }
        }
    }
}

struct DeleteButton_Previews: PreviewProvider {
    static var previews: some View {
        DeleteButton() {}
    }
}
