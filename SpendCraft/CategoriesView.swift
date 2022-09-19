//
//  CategoriesView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/18/22.
//

import SwiftUI

struct CategoriesView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink {
                    RegisterView()
                } label: {
                    Label("Unassigned", systemImage: "info.circle")
                }
                NavigationLink {
                    RegisterView()
                } label: {
                    Label("Test 2", systemImage: "info.circle")
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("Categories")
        }
    }
}

struct CategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        CategoriesView()
    }
}
