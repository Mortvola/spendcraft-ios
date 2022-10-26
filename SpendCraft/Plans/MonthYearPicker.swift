//
//  MonthYearPicker.swift
//  SpendCraft
//
//  Created by Richard Shields on 10/25/22.
//

import SwiftUI

struct MonthYearPicker: View {
    @Binding var date: MonthYearDate?
    @State var month: Int = 1
    @State var year: Int = 2022
    @Binding var isOpen: Bool

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Spacer()
                    Button("<<") {
                        year -= 1
                    }
                    Spacer()
                    Text("\(year)")
                    Spacer()
                    Button(">>") {
                        year += 1
                    }
                    Spacer()
                }
                .padding([.top, .bottom], 16)
                HStack {
                    CalendarButton(month: 1, selected: $month)
                    Spacer()
                    CalendarButton(month: 2, selected: $month)
                    Spacer()
                    CalendarButton(month: 3, selected: $month)
                }
                .padding(.bottom, 4)
                HStack {
                    CalendarButton(month: 4, selected: $month)
                    Spacer()
                    CalendarButton(month: 5, selected: $month)
                    Spacer()
                    CalendarButton(month: 6, selected: $month)
                }
                .padding(.bottom, 4)
                HStack {
                    CalendarButton(month: 7, selected: $month)
                    Spacer()
                    CalendarButton(month: 8, selected: $month)
                    Spacer()
                    CalendarButton(month: 9, selected: $month)
                }
                .padding(.bottom, 4)
                HStack {
                    CalendarButton(month: 10, selected: $month)
                    Spacer()
                    CalendarButton(month: 11, selected: $month)
                    Spacer()
                    CalendarButton(month: 12, selected: $month)
                }
                Button(action: { month = 0 }) {
                    Spacer()
                    Text("No Date")
                        .padding([.top,  .bottom])
                        .foregroundColor(.black)
                    Spacer()
                }
                .border(.gray, width:  1)
                .background(month == 0 ? Color(uiColor: .lightGray) : nil)
                Spacer()
            }
            .padding([.leading, .trailing])
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isOpen = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        if (month == 0) {
                            date = nil
                        } else {
                            date = MonthYearDate(month: month, year: year)
                        }
                        isOpen = false
                    }
                }
            }
            .onAppear {
                if let date = date {
                    month = date.month
                    year = date.year
                }
                else {
                    let now = MonthYearDate(date: Date.now)
                    month = 0
                    year = now.year
                }
            }
        }
    }
}

struct MonthYearPicker_Previews: PreviewProvider {
    static let date: MonthYearDate? = MonthYearDate(date: Date.now)
    static var previews: some View {
        Group {
            MonthYearPicker(date: .constant(nil), isOpen: .constant(true))
        }
    }
}
