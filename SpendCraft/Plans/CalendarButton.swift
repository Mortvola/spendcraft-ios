//
//  CalendarButton.swift
//  SpendCraft
//
//  Created by Richard Shields on 10/25/22.
//

import SwiftUI

let months: [String] = [
    "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"
]

struct CalendarButton: View {
    var month: Int
    @Binding var selected: Int
    
    var body: some View {
        Button(action: { selected = month }) {
            HStack {
                Spacer()
                Text(months[month - 1])
                    .padding([.top, .bottom])
                    .foregroundColor(.black)
                Spacer()
            }
        }
        .border(.gray, width: 1)
        .buttonBorderShape(.roundedRectangle)
        .background(selected == month ? Color(uiColor: .lightGray) : nil)
    }
}

struct CalendarButton_Previews: PreviewProvider {
    static var previews: some View {
        CalendarButton(month: 1, selected: .constant(1))
    }
}
