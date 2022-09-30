//
//  AccountsView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/18/22.
//

import SwiftUI

struct AccountsView: View {
    @StateObject private var accountsStore = AccountsStore();

    var body: some View {
        NavigationView {
            List($accountsStore.accounts) {
                InstitutionView(institution: $0)
            }
            .listStyle(.sidebar)
            .navigationTitle("Accounts")
        }
        .onAppear {
            AccountsStore.load(completion: { result in
                switch result {
                case .failure(let error):
                    fatalError(error.localizedDescription)
                case .success(let accounts):
                    self.accountsStore.accounts = accounts
                }
            })
        }
    }
}

struct AccountsView_Previews: PreviewProvider {
    static var previews: some View {
        AccountsView()
    }
}
