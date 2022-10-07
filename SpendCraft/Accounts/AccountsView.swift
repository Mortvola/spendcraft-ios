//
//  AccountsView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/18/22.
//

import SwiftUI

struct AccountsView: View {
    @EnvironmentObject private var navModel: NavModel
    @ObservedObject private var accountsStore = AccountsStore.shared;

    var body: some View {
        NavigationSplitView {
            List($accountsStore.accounts, selection: $navModel.selectedAccount) {
                InstitutionView(institution: $0)
            }
            .listStyle(.sidebar)
            .navigationTitle("Accounts")
            .refreshable {
                accountsStore.load()
            }
        } detail: {
            if let account = navModel.selectedAccount {
                AccountRegisterView(account: account)
            }
        }
        .onAppear {
            if (!accountsStore.loaded) {
                accountsStore.load()
            }
        }
    }
}

struct AccountsView_Previews: PreviewProvider {
    static var previews: some View {
        AccountsView()
    }
}
