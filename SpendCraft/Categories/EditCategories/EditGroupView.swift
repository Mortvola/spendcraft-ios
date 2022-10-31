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
    @State var hidden: Bool = false
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
                Toggle("Hidden", isOn: $hidden)
                ControlGroup {
                    DeleteButton() {
                        Task {
                            await categoriesStore.deleteGroup(group: group)
                            isOpen = false
                        }
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
                        Task {
                            await categoriesStore.updateGroup(group: group, name: name, hidden: hidden)
                            isOpen = false
                        }
                    }
                    .disabled(name.isEmpty)
                }
            }
            .onAppear {
                name = group.name
                hidden = group.hidden
                
                nameInFocus = true
            }
        }
    }
}

struct EditGroupView_Previews: PreviewProvider {
    static let group = SpendCraft.Group(id: 0, name: "Test", type: .regular, hidden: false, categories: [])

    static var previews: some View {
        EditGroupView(group: group, isOpen: .constant(true))
    }
}
