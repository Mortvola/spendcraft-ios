//
//  AddGroupView.swift
//  SpendCraft
//
//  Created by Richard Shields on 10/12/22.
//

import SwiftUI

struct AddGroupView: View {
    @Binding var isOpen: Bool
    @State var name: String = ""
    var categoriesStore = CategoriesStore.shared
    @FocusState private var nameInFocus: Bool

    var body: some View {
        NavigationStack {
            Form {
                LabeledContent("Name") {
                    TextField("Name", text: $name)
                        .multilineTextAlignment(.trailing)
                        .lineLimit(1)
                        .focused($nameInFocus)
                }
            }
            .navigationTitle("Add Group")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isOpen = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        isOpen = false;
                        categoriesStore.addGroup(name: name)
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
        .onAppear {
            nameInFocus = true
        }
    }
}

struct AddGroupView_Previews: PreviewProvider {
    static var previews: some View {
        AddGroupView(isOpen: .constant(true))
    }
}
