//
//  EditingGroupView.swift
//  SpendCraft
//
//  Created by Richard Shields on 10/12/22.
//

import SwiftUI
import Framework

struct EditGroupView: View {
    var categoriesStore = CategoriesStore.shared
    @ObservedObject var group: SpendCraft.Group
    @Binding var isOpen: Bool
    @State var name: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                LabeledContent("Name") {
                    TextField("Name", text: $name)
                        .multilineTextAlignment(.trailing)
                        .lineLimit(1)
                }
                ControlGroup {
                    DeleteButton() {
                        isOpen = false
                        categoriesStore.deleteGroup(group: group)
                    }
                }
            }
            .navigationTitle("Edit Group")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isOpen = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        isOpen = false
                        categoriesStore.updateGroup(group: group, name: name)
                    }
                    .disabled(name.isEmpty)
                }
            }
            .onAppear {
                name = group.name
            }
        }
    }
}

struct EditGroupView_Previews: PreviewProvider {
    static let group = SpendCraft.Group(id: 0, name: "Test", type: .regular, categories: [])

    static var previews: some View {
        EditGroupView(group: group, isOpen: .constant(true))
    }
}
