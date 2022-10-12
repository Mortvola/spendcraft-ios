//
//  AddGroupView.swift
//  SpendCraft
//
//  Created by Richard Shields on 10/12/22.
//

import SwiftUI

struct AddGroupView: View {
    @Binding var isAddingGroup: Bool
    @State var name: String = ""
    var categoriesStore = CategoriesStore.shared

    var body: some View {
        NavigationStack {
            Form {
                LabeledContent("Name") {
                    TextField("Name", text: $name)
                        .multilineTextAlignment(.trailing)
                        .lineLimit(1)
                }
            }
            .navigationTitle("Add Group")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isAddingGroup = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        isAddingGroup = false;
                        categoriesStore.addGroup(name: name)
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

struct AddGroupView_Previews: PreviewProvider {
    static var previews: some View {
        AddGroupView(isAddingGroup: .constant(true))
    }
}
