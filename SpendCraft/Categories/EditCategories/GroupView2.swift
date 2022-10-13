//
//  GroupView2.swift
//  SpendCraft
//
//  Created by Richard Shields on 10/12/22.
//

import SwiftUI
import Framework

struct GroupView2: View {
    @ObservedObject var group: SpendCraft.Group
    @State var isEditing = false
    
    var body: some View {
        Group {
            Button(action: {
                isEditing = true
            }) {
                Text(group.name)
            }
            ForEach(group.categories) { category in
                CategoryView2(category: category)
                    .padding(.leading)
            }
        }
        .sheet(isPresented: $isEditing) {
            EditGroupView(group: group, isOpen: $isEditing)
                .presentationDetents([.medium])
        }
    }
}

struct GroupView2_Previews: PreviewProvider {
    static let group = SpendCraft.Group(id: 0, name: "Test", type: .regular, categories: [])
    
    static var previews: some View {
        GroupView2(group: group)
    }
}
