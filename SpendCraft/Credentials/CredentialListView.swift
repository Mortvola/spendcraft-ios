//
//  CredentialListView.swift
//  SpendCraft
//
//  Created by Richard Shields on 1/21/23.
//

import SwiftUI

struct CredentialListView: View {
    @Binding var show: Bool
    @Binding var credentials: [Creds]
    @Binding var selection: Int

    var body: some View {
        VStack {
            Text("This device has used multiple accounts to signin with. Which account would you like to use?")
            List {
                ForEach(credentials.indices, id: \.self) { index in
                    Button {
                        show = false
                        selection = index
                    } label: {
                        Text(credentials[index].username)
                    }
                }
            }
        }
        .padding()
    }
}

struct CredentialListView_Previews: PreviewProvider {
    static var previews: some View {
        CredentialListView(show: .constant(true), credentials: .constant([]), selection: .constant(-1))
    }
}
