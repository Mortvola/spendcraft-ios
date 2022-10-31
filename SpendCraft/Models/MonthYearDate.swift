//
//  MonthDateYear.swift
//  SpendCraft
//
//  Created by Richard Shields on 10/30/22.
//

import Foundation
import Framework

struct MonthYearDate: Encodable {
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
    
    init(month: Int, year: Int) {
        self.calendar = Calendar.current
        self.calendar.timeZone = TimeZone(abbreviation: "UTC")!

        self.month = month
        self.year = year
    }
    
    func date() throws -> Date {
        try MonthYearDate.monthDate(month: self.month, year: self.year)
    }
    
    static private func monthDate(month: Int, year: Int) throws -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let date = formatter.date(from: "\(year)-\(String(format: "%02d", month))-01")
        
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
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode("\(self.year)-\(String(format: "%02d", self.month))-01")
    }
    
    func diff(other: MonthYearDate) -> Int {
        return (self.year - other.year) * 12 + self.month - other.month
    }
}

