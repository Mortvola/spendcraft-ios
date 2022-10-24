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
    var goalDate: Date?
    var useGoal: Bool
    
    init(response: Response.PlanCategory) {
        self.id = response.id
        self.categoryId = response.categoryId
        self.amount = response.amount
        self.recurrence = response.recurrence
        self.goalDate = response.goalDate
        self.useGoal = response.useGoal
    }
    
    struct Data {
        var amount: Double?
        var recurrence: Int = 1
        var goalMonth: Int = 1
        var goalYear: Int = 2022
        
        var goalDate: Date? {
            get {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                formatter.timeZone = TimeZone(abbreviation: "UTC")
                
                return formatter.date(from: "\(self.goalYear)-\(self.goalMonth + 1)-01")
            }
        }
        
        init() {}

        init(amount: Double?, recurrence: Int, goalDate: Date?) {
            self.amount = amount
            self.recurrence = recurrence
            
            let calendar = Calendar.current
            let currentComponents = calendar.dateComponents([.month, .year], from: Date.now)
            let currentYear: Int = currentComponents.year!
            let currentMonth: Int = currentComponents.month!
            
            if let goalDate = goalDate {
                let components = calendar.dateComponents([.month, .year], from: goalDate)
                goalMonth = components.month ?? currentMonth
                goalYear = components.year ?? currentYear
            }
            else {
                goalMonth = currentMonth
                goalYear = currentYear
            }
        }
    }
    
    func data() -> Data {
        PlanCategory.Data(amount: self.amount, recurrence: self.recurrence, goalDate: self.goalDate)
    }

    func save(data: Data) {
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
                    
                    let dateString = formatter.string(from: goalDate)
                    try container.encode(dateString, forKey: .goalDate)
                }
            }
        }
        
        let requestData = RequestData(amount: data.amount ?? 0, useGoal: false, goalDate: data.goalDate, recurrence: data.recurrence)
        
        try? Http.put(path: "/api/funding-plans/10/item/\(self.categoryId)", data: requestData) { _ in
            DispatchQueue.main.async {
                self.amount = data.amount ?? 0
                self.recurrence = data.recurrence
                self.goalDate = data.goalDate
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
