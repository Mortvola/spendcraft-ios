//
//  BusyView.swift
//  SpendCraft
//
//  Created by Richard Shields on 1/27/23.
//

import SwiftUI
import Framework

struct BusyView: ViewModifier {
    @ObservedObject var busy = Busy.shared
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        ZStack {
            content
                .interactiveDismissDisabled(busy.busy)
            if busy.busy {
                ProgressView()
                    .padding(64)
                    .background(Color(colorScheme == .dark ? .black : .white))
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(.gray, lineWidth: 1))
            }
        }
    }
}

extension View {
    func withBusyIndicator() -> some View {
        modifier(BusyView())
    }
}
