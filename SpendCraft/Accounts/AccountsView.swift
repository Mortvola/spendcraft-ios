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
            List {
                ForEach($accountsStore.accounts) { $institution in
                    InstitutionView(institution: $institution)
                }
            }
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
