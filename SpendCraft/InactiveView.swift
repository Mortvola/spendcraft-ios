//
//  BlankView.swift
//  SpendCraft
//
//  Created by Richard Shields on 10/1/22.
//

import SwiftUI

struct InactiveView: View {
    var body: some View {
        VStack {
            Spacer()
            Image(uiImage: UIImage(named: "Logo") ?? UIImage())
                .resizable()
                .aspectRatio(contentMode: .fit)
            Spacer()
        }
    }
}

struct InactiveView_Previews: PreviewProvider {
    static var previews: some View {
        InactiveView()
    }
}
