//
//  helpers.swift
//  Geo-Trax
//
//  Created by Stephen Wall on 4/7/20.
//  Copyright © 2020 syntaks.io. All rights reserved.
//


import Foundation

extension Double {
    func truncate(places : Int) -> Double {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}

extension Date {
    static func getFormattedDate(date: Date) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = "MM-dd-yyyy HH:mm:ss"
        return dateformat.string(from: date)
    }
    
    static func getDurationBetween(_ startDate: Date, and endDate: Date) -> String {
        let duration = startDate.distance(to: endDate)
        let ti = NSInteger(duration)
        let hours = (ti / 3600)
        let minutes = (ti / 60) % 60
        var value: String
        if hours > 0 {
            value = "\(hours) Hour \(minutes) Min"
        } else {
            value = "\(minutes) Min"
        }
        return value
    }
    
    static func startOfDay(day: Date) -> Date {
        let gregorian = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        let unitFlags: NSCalendar.Unit = [.minute, .hour, .day, .month, .year]
        var todayComponents = gregorian!.components(unitFlags, from: day)
        todayComponents.hour = 0
        todayComponents.minute = 0
        return (gregorian?.date(from: todayComponents))!
    }

    static func endOfDay(day: Date) -> Date {
        let gregorian = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        let unitFlags: NSCalendar.Unit = [.minute, .hour, .day, .month, .year]
        var todayComponents = gregorian!.components(unitFlags, from: day)
        todayComponents.hour = 23
        todayComponents.minute = 59
        return (gregorian?.date(from: todayComponents))!
    }
    
    static func getStartOfDayString(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "en_US")
        return dateFormatter.string(from: date)
    }
}
