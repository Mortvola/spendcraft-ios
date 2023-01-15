//
//  PlanStore.swift
//  SpendCraft
//
//  Created by Richard Shields on 10/22/22.
//

import Foundation
import Framework
import Http

class Plan: ObservableObject {
    var id: Int
    var name: String
    @Published var categories: [PlanCategory]
    @Published var total: Double = 0.0
    
    init(response: Response.Plan) {
        self.id = response.id
        self.name = response.name
        self.categories = response.categories.map {
            PlanCategory(response: $0)
        }
        
        self.total = self.categories.reduce(0.0) { result, planCategory in
            result + planCategory.amount / Double(planCategory.recurrence)
        }
    }
}

class PlanCategory: ObservableObject {
    var id: Int
    var categoryId: Int
    @Published var amount: Double
    @Published var recurrence: Int
    var goalDate: MonthYearDate?
    var useGoal: Bool
    var expectedToSpend: Double?
    
    init(response: Response.PlanCategory) {
        self.id = response.id
        self.categoryId = response.categoryId
        self.amount = response.amount
        self.recurrence = response.recurrence
        
        if let goalDate = response.goalDate {
            self.goalDate = MonthYearDate(date: goalDate)
        }
        
        self.useGoal = response.useGoal
        self.expectedToSpend = response.expectedToSpend
    }
    
    struct Data {
        var amount: Double?
        var recurrence: Int = 1
        var goal: MonthYearDate? = nil
        var expectedToSpend: Double? = nil
        
        private var calendar: Calendar
        
        init() {
            self.calendar = Calendar.current
            self.calendar.timeZone = TimeZone(abbreviation: "UTC")!
        }

        init(amount: Double?, recurrence: Int, goalDate: MonthYearDate?, expectedToSpend: Double?) throws {
            self.calendar = Calendar.current
            self.calendar.timeZone = TimeZone(abbreviation: "UTC")!

            self.amount = amount
            self.recurrence = recurrence

            self.goal = goalDate

            if let goalDate = goalDate {
                let date = try goalDate.date()
                let now = try MonthYearDate.now()
                
                // If the date is in the past then adjust it so that it is in the future
                if now > date {
                    self.goal = try goalDate.nextDate(recurrence: self.recurrence)
                }
            }
            
            self.expectedToSpend = expectedToSpend
        }
    }
    
    func data() throws -> Data {
        try PlanCategory.Data(amount: self.amount, recurrence: self.recurrence, goalDate: self.goalDate, expectedToSpend: self.expectedToSpend)
    }

    @MainActor
    func save(data: Data) async throws {
        struct RequestData: Encodable {
            let amount: Double
            let useGoal: Bool
            let goalDate: MonthYearDate?
            let recurrence: Int
            let expectedToSpend: Double?
            
            init(amount: Double, useGoal: Bool, goalDate: MonthYearDate?, recurrence: Int, expectedToSpend: Double?) {
                self.amount = amount
                self.useGoal = useGoal
                self.recurrence = recurrence
                
                if (recurrence > 1) {
                    self.goalDate = goalDate
                }
                else {
                    self.goalDate = nil
                }
                
                self.expectedToSpend = expectedToSpend
            }
        }
        
        let requestData = RequestData(amount: data.amount ?? 0, useGoal: false, goalDate: data.goal, recurrence: data.recurrence, expectedToSpend: data.expectedToSpend)
        
        try await Http.put(path: "/api/funding-plans/10/item/\(self.categoryId)", data: requestData)

        self.amount = data.amount ?? 0
        self.recurrence = data.recurrence
        self.goalDate = data.goal
    }
}

class PlanStore: ObservableObject {
    @Published var plan: Plan?
    
    @Published var loaded = false

    static let shared: PlanStore = PlanStore()
    
    @MainActor
    func load() async {
        self.loaded = false
        if let response: Http.Response<Response.Plan> = try? await Http.get(path: "/api/funding-plans/10/details") {
            if let response = response.data {
                self.plan = Plan(response: response)
            }
        }

        self.loaded = true
    }
    
    static private var next = 0
    
    static func nextId() -> Int {
        next -= 1
        
        return next
    }

    func planCategory(_ category: SpendCraft.Category) -> PlanCategory {
        let planCat = self.plan?.categories.first {
            $0.categoryId == category.id
        }
        
        if let planCat = planCat {
            return planCat
        }
        
        return PlanCategory(response: Response.PlanCategory(id: PlanStore.nextId(), categoryId: category.id, amount: 0.0, recurrence: 1, useGoal: false, goalDate: Date.now, expectedToSpend: nil))
    }
}
