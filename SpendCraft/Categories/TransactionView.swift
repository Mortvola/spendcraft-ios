//
//  TransactionView.swift
//  SpendCraft
//
//  Created by Richard Shields on 9/21/22.
//

import SwiftUI

struct TransactionView: View {
    @Binding var trx: Transaction
    @Binding var transactions: [Transaction]
    @ObservedObject var category: CategoriesStore.Category
    @State var data = Transaction.Data()
    @State var isEditingTrx = false
    
    func formatAccount(institution: String?, account: String?) -> String {
        guard let institution = institution, let account = account else {
            return ""
        }
        
        if (institution != "" && account != "") {
            return "\(institution): \(account)"
        }
        
        return ""
    }

    var body: some View {
        Button(action: {
            isEditingTrx = true
            data = trx.data
        }) {
            VStack(spacing: 10) {
                HStack() {
                    HStack {
                        Text(trx.name)
                            .lineLimit(1)
                        Spacer()
                    }
                    AmountView(amount: trx.categoryAmount(category: category))
                }
                
                HStack {
                    Text(formatDate(date: trx.date))
                    Text(formatAccount(institution: trx.institution, account:  trx.account))
                        .lineLimit(1)
                    Spacer()
                    AmountView(amount: trx.runningBalance ?? 0)
                }
                .font(.caption)

                if (!trx.accountOwner.isEmpty) {
                    HStack {
                        Text(trx.accountOwner)
                            .font(.caption)
                            .lineLimit(1)
                        Spacer()
                    }
                }
            }
        }
        .sheet(isPresented: $isEditingTrx) {
            NavigationStack {
                TransactionEdit(transaction: $trx, isEditingTrx: $isEditingTrx, trxData: $data, transactions: $transactions, category: category)
            }
        }
    }
}

struct TransactionView_Previews: PreviewProvider {
    static let category = CategoriesStore.Category(id: 0, groupId: 0, name: "Test", balance: 0, type: .regular, monthlyExpenses: false)

    static var previews: some View {
        TransactionView(trx: .constant(SampleData.transactions[0]), transactions: .constant(SampleData.transactions), category: category)
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
