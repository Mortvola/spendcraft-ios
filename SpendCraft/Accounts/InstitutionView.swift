//
//  InstitutionView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/29/22.
//

import SwiftUI

struct InstitutionView: View {
    @Binding var institution: Institution
    
    func formatDate(date: Date?) -> String {
        if let date = date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            
            let s = dateFormatter.string(from: date)
            return s
        }
        
        return "None"
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(institution.name)
                    .padding(.top)
                Spacer()
            }
            ForEach(institution.accounts.filter { account in
                !account.closed
            }) { account in
                VStack(alignment: .leading) {
                    Text(account.name)
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
                .border(Color.black, width: 1)
                .padding(.top)
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
