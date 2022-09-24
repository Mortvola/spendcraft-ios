//
//  TransactionView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/21/22.
//

import SwiftUI

struct TransactionView: View {
    @Binding var trx: Transaction
    @State var data = Transaction.Data()
    @State var isEditingTrx = false
    let categories: Categories
    
    func formatAccount(institution: String?, account: String?) -> String {
        guard let institution = institution, let account = account else {
            return ""
        }
        
        if (institution != "" && account != "") {
            return "\(institution): \(account)"
        }
        
        return ""
    }

    func saveTransaction() {
        trx.save() { result in
            switch result {
            case .failure(let error):
                fatalError(error.localizedDescription)
            case .success:
                print("transaction saved")
            }
        }
    }

    var body: some View {
        Button(action: {
            isEditingTrx = true
            data = trx.data
        }) {
            VStack(alignment: .leading) {
                HStack() {
                    Text(formatDate(date: trx.date))
                    HStack {
                        Text(trx.name)
                        Spacer()
                    }
                    AmountView(amount: trx.amount)
                }
                
                HStack {
                    Text(formatAccount(institution: trx.institution, account:  trx.account))
                        .font(.caption)
                }
            }
        }
        .sheet(isPresented: $isEditingTrx) {
            NavigationView {
                TransactionEdit(transaction: $data, categories: categories)
                .navigationTitle("Editing Transaction")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            isEditingTrx = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            isEditingTrx = false;
                            trx.update(from: data)
                            saveTransaction()
                            // scrum.update(from: data)
                        }
                    }
                }
            }
        }
    }
}

struct TransactionView_Previews: PreviewProvider {
    static let categories = Categories(tree: [])

    static var previews: some View {
        TransactionView(trx: .constant(Transaction.sampleData[0]), categories: categories)
    }
}


/*

 PATCH https://spendcraft.app/api/transaction/9067

 {
    "name":"Garmin",
    "date":"2022-09-22",
    "amount":-64.95,
    "principle":0,
    "comment":"",
    "splits":[
        {
            "id":-2,
            "categoryId":4,
            "amount":-64.95
        }
    ]
 }
 
 {
     "categories": [
         {
             "id": -2,
             "balance": -719.39
         },
         {
             "id": 4,
             "balance": 277.93
         }
     ],
     "acctBalances": [
         {
             "id": 180,
             "balance": -8302.83
         }
     ],
     "transaction": {
         "id": 9067,
         "createdAt": "2022-09-24T07:39:05.465+00:00",
         "date": "2022-09-22",
         "sortOrder": null,
         "type": 0,
         "comment": null,
         "duplicateOfTransactionId": null,
         "transactionCategories": [
             {
                 "id": 6352,
                 "categoryId": 4,
                 "amount": -64.95,
                 "comment": null
             }
         ],
         "accountTransaction": {
             "name": "Garmin",
             "amount": -64.95,
             "paymentChannel": "online",
             "principle": 0,
             "location": {
                 "address": null,
                 "city": null,
                 "region": "KS",
                 "postalCode": null,
                 "country": null,
                 "lat": null,
                 "lon": null,
                 "storeNumber": null
             },
             "accountOwner": "RICHARD H SHIELDS",
             "account": {
                 "id": 180,
                 "name": "Costco Anywhere Visa® Business Card by Citi-2812"
             }
         }
     }
 }
*/