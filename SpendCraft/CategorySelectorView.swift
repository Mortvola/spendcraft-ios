//
//  CategorySelectorView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/20/22.
//

import SwiftUI

struct CategorySelectorView: View {
    @Binding var selection: Int

    var body: some View {
        Picker("Color", selection: $selection) {
            Text("Red").tag(1)
            Text("Blue").tag(2)
            Text("Green").tag(3)
        }
    }
}

struct CategorySelectorView_Previews: PreviewProvider {
    static let selection: Int = 2
    
    static var previews: some View {
        CategorySelectorView(selection: .constant(selection))
    }
}
