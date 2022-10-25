//
//  PlanStore.swift
//  SpendCraft
//
//  Created by Richard Shields on 10/22/22.
//

import Foundation
import Framework

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
    
    init(response: Response.PlanCategory) {
        self.id = response.id
        self.categoryId = response.categoryId
        self.amount = response.amount
        self.recurrence = response.recurrence
        
        if let goalDate = response.goalDate {
            self.goalDate = MonthYearDate(date: goalDate)
        }
        
        self.useGoal = response.useGoal
    }
    
    struct MonthYearDate {
        var month: Int
        var year: Int
        private var calendar: Calendar

        init(date: Date) {
            self.calendar = Calendar.current
            self.calendar.timeZone = TimeZone(abbreviation: "UTC")!

            let components = self.calendar.dateComponents([.month, .year], from: date)
            
            self.month = components.month!
            self.year = components.year!
        }
        
        func date() throws -> Date {
            try MonthYearDate.monthDate(month: self.month, year: self.year)
        }
        
        static private func monthDate(month: Int, year: Int) throws -> Date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            
            let date = formatter.date(from: "\(year)-\(month)-01")
            
            guard let date = date else {
                throw MyError.runtimeError("date is invalid")
            }

            return date
        }
        
        static func now() throws -> Date {
            var calendar = Calendar.current
            calendar.timeZone = TimeZone(abbreviation: "UTC")!

            let components = calendar.dateComponents([.month, .year], from: Date.now)
            
            guard let month = components.month, let year = components.year else {
                throw MyError.runtimeError("Invalid date")
            }

            return try MonthYearDate.monthDate(month: month, year: year)
        }
        
        private func getComponents(date: Date) throws -> (Int, Int) {
            let components = self.calendar.dateComponents([.month, .year], from: date)
            
            guard let month = components.month, let year = components.year else {
                throw MyError.runtimeError("Invalid date")
            }
            
            return (month, year)
        }

        func nextDate(recurrence: Int) throws -> MonthYearDate {
            let now = try MonthYearDate.now()

            // Get the number of months in the past
            let months = self.calendar.dateComponents([.month], from: try self.date(), to: now).month ?? 0
            
            // Determine how many months to add to the current month to get the future month
            let monthsInFuture = recurrence - months % recurrence
            
            let future = self.calendar.date(byAdding: .month, value: monthsInFuture, to: now)
            
            guard let future = future else {
                throw MyError.runtimeError("future is invalid")
            }

            return MonthYearDate(date: future)
        }
    }

    struct Data {
        var amount: Double?
        var recurrence: Int = 1
        var goal: MonthYearDate
        
        private var calendar: Calendar
        
        init() {
            self.calendar = Calendar.current
            self.calendar.timeZone = TimeZone(abbreviation: "UTC")!
            
            self.goal = MonthYearDate(date: Date.now)
        }

        init(amount: Double?, recurrence: Int, goalDate: MonthYearDate?) throws {
            self.calendar = Calendar.current
            self.calendar.timeZone = TimeZone(abbreviation: "UTC")!

            self.amount = amount
            self.recurrence = recurrence
            
            if let goalDate = goalDate {
                self.goal = goalDate
                
                let date = try self.goal.date()
                let now = try MonthYearDate.now()
                
                // If the date is in the past then adjust it so that it is in the future
                if now > date {
                    self.goal = try self.goal.nextDate(recurrence: self.recurrence)
                }
            }
            else {
                self.goal = MonthYearDate(date: Date.now)
            }
        }
    }
    
    func data() throws -> Data {
        try PlanCategory.Data(amount: self.amount, recurrence: self.recurrence, goalDate: self.goalDate)
    }

    func save(data: Data) throws {
        struct RequestData: Encodable {
            let amount: Double
            let useGoal: Bool
            let goalDate: Date?
            let recurrence: Int

            enum CodingKeys: String, CodingKey {
                case amount
                case useGoal
                case goalDate
                case recurrence
            }

            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(self.amount, forKey: .amount)
                try container.encode(self.useGoal, forKey: .useGoal)
                try container.encode(self.recurrence, forKey: .recurrence)

                if let goalDate = goalDate {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    formatter.timeZone = TimeZone(abbreviation: "UTC")!
                    
                    let dateString = formatter.string(from: goalDate)
                    try container.encode(dateString, forKey: .goalDate)
                }
            }
        }
        
        let requestData = RequestData(amount: data.amount ?? 0, useGoal: false, goalDate: try data.goal.date(), recurrence: data.recurrence)
        
        try? Http.put(path: "/api/funding-plans/10/item/\(self.categoryId)", data: requestData) { _ in
            DispatchQueue.main.async {
                self.amount = data.amount ?? 0
                self.recurrence = data.recurrence
                self.goalDate = data.goal
            }
        }
    }
}

class PlanStore: ObservableObject {
    @Published var plan: Plan?
    
    @Published var loaded = false

    static let shared: PlanStore = PlanStore()
    
    func load() {
        self.loaded = false
        try? Http.get(path: "/api/funding-plans/10/details") { data in
            guard let data = data else {
                return
            }
            
            let response: Response.Plan
            do {
                response = try JSONDecoder().decode(Response.Plan.self, from: data)
            }
            catch {
                print ("Error: \(error)")
                return
            }
            
            DispatchQueue.main.async {
                self.plan = Plan(response: response)
                self.loaded = true
            }
        }
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
        
        return PlanCategory(response: Response.PlanCategory(id: PlanStore.nextId(), categoryId: category.id, amount: 0.0, recurrence: 1, useGoal: false))
    }
}
