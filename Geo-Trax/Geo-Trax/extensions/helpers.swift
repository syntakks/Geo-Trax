//
//  helpers.swift
//  Geo-Trax
//
//  Created by Stephen Wall on 4/7/20.
//  Copyright © 2020 syntaks.io. All rights reserved.
//


import Foundation

extension Double {
    func truncate(places : Int)-> Double {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}

extension Date {
    static func getFormattedDate(date: Date) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = "MM-dd-yyyy HH:mm:ss"
        return dateformat.string(from: date)
    }
}
