//
//  AccountsView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/18/22.
//

import SwiftUI

struct AccountsView: View {
    @EnvironmentObject private var navModel: NavModel
    @StateObject private var accountsStore = AccountsStore();

    func loadAccounts() {
        AccountsStore.load(completion: { result in
            switch result {
            case .failure(let error):
                fatalError(error.localizedDescription)
            case .success(let accounts):
                self.accountsStore.accounts = accounts
            }
        })
    }
    
    var body: some View {
        NavigationSplitView {
            List($accountsStore.accounts, selection: $navModel.selectedAccount) {
                InstitutionView(institution: $0)
            }
            .listStyle(.sidebar)
            .navigationTitle("Accounts")
            .refreshable {
                loadAccounts()
            }
        } detail: {
            if let account = navModel.selectedAccount {
                AccountRegisterView(account: account)
            }
        }
        .onAppear {
            loadAccounts()
        }
    }
}

struct AccountsView_Previews: PreviewProvider {
    static var previews: some View {
        AccountsView()
    }
}
