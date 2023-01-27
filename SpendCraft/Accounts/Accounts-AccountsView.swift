//
//  AccountsView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/18/22.
//

import SwiftUI

extension Accounts {
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
                    await accountsStore.load(force: true)
                }
            } detail: {
                if let account = navModel.selectedAccount {
                    Accounts.RegisterView(account: account)
                }
            }
            .task {
                await accountsStore.load()
            }
        }
    }
    
    struct AccountsView_Previews: PreviewProvider {
        static var previews: some View {
            AccountsView()
        }
    }
}
