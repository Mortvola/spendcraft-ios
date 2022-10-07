//
//  InstitutionView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/29/22.
//

import SwiftUI

struct InstitutionView: View {
    @Binding var institution: Institution
    @State var isExpanded: Bool = true

    func formatDate(date: Date?) -> String {
        if let date = date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            
            return dateFormatter.string(from: date)
        }
        
        return "None"
    }

    var body: some View {
        DisclosureGroup(institution.name, isExpanded: $isExpanded) {
            ForEach($institution.accounts.filter { $account in
                !account.closed
            }) { $account in
                NavigationLink(destination: AccountRegisterView(institution: $institution, account: $account)) {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Name")
                            Spacer()
                            Text(account.name)
                                .lineLimit(1)
                        }
                        HStack {
                            Text("Balance")
                            Spacer()
                            AmountView(amount: account.balance)
                        }
                        HStack {
                            Text("As Of")
                            Spacer()
                            Text(formatDate(date: account.syncDate))
                        }
                    }
//                    .border(Color.black, width: 1)
//                    .padding(.top)
                }
            }
            .padding(.leading)
            .font(.body)
        }
        .font(.headline)
    }
}

struct InstitutionView_Previews: PreviewProvider {
    static let institution = Institution(id: 0, name: "Test Institution", accounts: [
        Account(id: 0, name: "Test Account One", balance: 100.0, closed: false),
        Account(id: 1, name: "Test Account Two", balance: 200.0, closed: false)
    ])

    static var previews: some View {
        InstitutionView(institution: .constant(institution))
    }
}
