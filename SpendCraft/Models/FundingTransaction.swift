//
//  FundingTransaction.swift
//  SpendCraft
//
//  Created by Richard Shields on 11/4/22.
//

import Foundation
import Framework
import Http

class FundingTransaction: Trx {
    struct Category: Identifiable, Codable {
        var id: Int?
        var categoryId: Int?
        var amount: Double?
        var allowed: Double?
        var adjusted: Bool = false
        var adjustedText: String = ""
        
        init() {
        }

        init(id: Int, categoryId: Int, amount: Double, comment: String?) {
            self.id = id
            self.categoryId = categoryId
            self.amount = amount
        }
        
        init(trxCategory: Response.Transaction.TransactionCategory) {
            self.id = trxCategory.id
            self.categoryId = trxCategory.categoryId
            self.amount = trxCategory.amount
            self.allowed = trxCategory.expected
        }

        static private var next = 0
        
        static func nextId() -> Int {
            next -= 1
            
            return next
        }
    }
    
    var categories: [Category] = []
    
    init(id: Int, date: String, name: String, amount: Double, institution: String, account: String, comment: String?, transactionCategories: [Category], type: TransactionType) {
        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "y-M-d"
        
        self.categories = transactionCategories
        
        super.init(id: id, date: dateFormatter.date(from: date), name: name, type: type, amount: amount)
    }
    
    override init(type: TransactionType) {
        self.categories = []
        
        super.init(type: type)
    }
    
    init(trx: Response.Transaction) {
        self.categories = trx.transactionCategories.map {
            Category(trxCategory: $0)
        }
        
        super.init(id: trx.id, date: trx.date, name: "", type: trx.type, amount: trx.accountTransaction?.amount ?? 0)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    func hasCategory(categoryId: Int) -> Bool {
        categories.contains {
            $0.id == categoryId
        }
    }
    
    override func categoryAmount(category: SpendCraft.Category) -> Double {
        if (category.type == CategoryType.unassigned) {
            return self.amount
        }

        return categories.reduce(0.0) { result, trxCategory in
            if (trxCategory.categoryId == category.id) {
                if let amount = trxCategory.amount {
                    return result + amount
                }
            }
            
            return result
        }
    }

    @MainActor
    func save() async {
        struct RequestData: Encodable {
            struct Category: Encodable {
                var categoryId: Int?
                var amount: Double?
                var expected: Double?
            }

            var date: String
            var categories: [Category]
            var type: TransactionType
        }

        guard let date = self.date else {
            return
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        let dateString = formatter.string(from: date)

        var requestData = RequestData(
            date: dateString,
            categories: self.categories.filter {
                ($0.amount ?? 0) != 0
            }.map {
                RequestData.Category(categoryId: $0.categoryId, amount: $0.amount, expected: $0.allowed)
            },
            type: .funding
        )
        
        let sum = requestData.categories.reduce(0.0) { accum, value in
            accum + (value.amount ?? 0)
        }
        
        print("sum = \(sum)")
        
        let categoriesStore = CategoriesStore.shared
        requestData.categories.append(RequestData.Category(categoryId: categoriesStore.fundingPool.id, amount: -sum))

        if self.id < 0 {
            if let result: Http.Response<Response.UpdateTransaction> = try? await Http.post(path: "/api/v1/category-transfer", data: requestData) {
                
                if result.hasErrors() {
                    result.printErrors()
                }
            }
        }
        else {
            if let result: Http.Response<Response.UpdateTransaction> = try? await Http.patch(path: "/api/v1/category-transfer/\(self.id)", data: requestData) {

                if result.hasErrors() {
                    result.printErrors()
                }
            }
        }
    }
}

extension FundingTransaction {
    struct Data {
        var transaction: FundingTransaction?
        var date: Date?
        var categories: [Category] = []

        var loaded = false
        
        init() {}
        
        init(_ transaction: FundingTransaction) {
            self.transaction = transaction
            self.date = transaction.date
            self.categories = transaction.categories
        }
        
        init(date: Date?, categories: [Category]) {
            self.date = date
            self.categories = categories
        }
        
        mutating func update(from data: FundingTransaction.Data) {
            self.transaction = data.transaction
            self.date = data.date
            self.categories = data.categories
            
            self.loaded = data.loaded
        }
        
        var isValid: Bool {
            categories.allSatisfy {
                $0.categoryId != nil && $0.amount != nil
            }
            && (categories.count == 0)
        }

        var allowedTotal: Double {
            return self.categories.reduce(0.0) { accum, category in
                if let amount = category.allowed {
                    return accum + amount
                }
                
                return accum
            }
        }

        var fundingTotal: Double {
            let categoriesStore = CategoriesStore.shared
            return self.categories.reduce(0.0) { accum, category in
                if category.categoryId != categoriesStore.fundingPool.id, let amount = category.amount {
                    return accum + amount
                }
                
                return accum
            }
        }
        
        func trxCategoryIndex(categoryId: Int) -> Int? {
            self.categories.firstIndex { category in
                category.categoryId == categoryId
            }
        }
    }
    
    func data() async -> Data {
        var data = Data(self)
        
        let categoriesStore = CategoriesStore.shared

        // Add categories from the category store that are not present in the transaction.
        categoriesStore.categoryDictionary.forEach { entry in
            if data.categories.first(where: { dataCat in
                dataCat.categoryId == entry.value.id
            }) == nil {
                let newCat = FundingTransaction.Category(id: Category.nextId(), categoryId: entry.value.id, amount: 0.0, comment: nil)
                data.categories.append(newCat)
            }
        }
        
        if self.id < 0 {
            // Get the plan and adjust amounts in each of the categories
            if let response: Http.Response<Response.Plan> = try? await Http.get(path: "/api/v1/funding-plans/10/details") {
                if let planResponse = response.data {
                    let fundingMonth = MonthYearDate(date: Date.now)
                    data.date = try? fundingMonth.date()
                    
                    planResponse.categories.forEach { planCat in
                        // Get the transaction category index
                        guard let categoryIndex = data.categories.firstIndex(where: {
                            $0.categoryId == planCat.categoryId
                        }) else {
                            return
                        }
                        
                        // Get the category
                        guard let category = categoriesStore.categoryDictionary[planCat.categoryId] else {
                            return
                        }
                        
                        if let gd = planCat.goalDate {
                            let goalDate = MonthYearDate(date: gd)
                            let monthDiff = goalDate.diff(other: fundingMonth)
                            
                            var monthlyAmount = 0.0
                            
                            let goalDiff = planCat.amount - category.balance
                            
                            if goalDiff > 0 {
                                monthlyAmount = goalDiff / Double(monthDiff + 1)
                            }
                            
                            data.categories[categoryIndex].amount = monthlyAmount
                            
                            if monthDiff == 0 {
                                data.categories[categoryIndex].allowed = planCat.amount
                            }
                            
                            let plannedAmount = planCat.amount / Double(planCat.recurrence)
                            if monthlyAmount != plannedAmount {
                                data.categories[categoryIndex].adjusted = true
                                data.categories[categoryIndex].adjustedText = "The funding amount was adjusted from a planned amount of \(SpendCraft.Amount(amount: plannedAmount)) to \(SpendCraft.Amount(amount: monthlyAmount)) for the goal of \(planCat.amount) due \(goalDate.year)-\(goalDate.month)."
                                print("Adjusted \(category.name): \(plannedAmount) to \(monthlyAmount)")
                            }
                        } else {
                            let plannedAmount = planCat.amount / Double(planCat.recurrence)
                            var monthlyAmount = plannedAmount
                            
                            // Adjust the monthly amount if this is a required amount (a bill)
                            // so that there is enough of a balance to meet its requirement
                            if category.balance < 0 {
                                monthlyAmount = plannedAmount - category.balance
                                print("Adjusted \(category.name): \(plannedAmount) to \(monthlyAmount)")
                                data.categories[categoryIndex].adjusted = true
                                data.categories[categoryIndex].adjustedText = "The funding amount was adjusted from a planned amount of \(SpendCraft.Amount(amount: plannedAmount)) to \(SpendCraft.Amount(amount: monthlyAmount))."
                            }
                            
                            data.categories[categoryIndex].amount = monthlyAmount
                            
                            if planCat.expectedToSpend != nil {
                                data.categories[categoryIndex].allowed = planCat.expectedToSpend
                            }
                            else {
                                let balance = category.balance + monthlyAmount
                                data.categories[categoryIndex].allowed = balance > 0 ? balance : 0
                            }
                        }
                    }
                }
            }

            data.loaded = true
        }

        return data
    }
    
    func update(from data: Data) {
        categories = data.categories.filter {
            $0.amount != 0
        }
    }
}
