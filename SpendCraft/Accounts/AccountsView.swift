//
//  AccountsView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/18/22.
//

import SwiftUI

struct AccountsView: View {
    @Binding var categories: Categories
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
        NavigationView {
            List($accountsStore.accounts) {
                InstitutionView(institution: $0, categories: $categories)
            }
            .listStyle(.sidebar)
            .navigationTitle("Accounts")
            .refreshable {
                loadAccounts()
            }
        }
        .onAppear {
            loadAccounts()
        }
    }
}

struct AccountsView_Previews: PreviewProvider {
    static var previews: some View {
        AccountsView(categories: .constant(SampleData.categories))
    }
}
