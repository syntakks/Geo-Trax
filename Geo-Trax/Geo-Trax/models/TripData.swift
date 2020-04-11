//
//  Trip.swift
//  Geo-Trax
//
//  Created by Stephen Wall on 4/6/20.
//  Copyright © 2020 syntaks.io. All rights reserved.
//

import Foundation

class TripData {
    var clientId: String?
    let startDate: Date
    var endDate: Date?
    var distanceMeters: Double
    var duration: Double {
           if let end = endDate {
               return startDate.distance(to: end)
           }
           return 0
       }
    var distanceMiles: Double {
        return (distanceMeters * 0.000621371).truncate(places: 3)
    }
    
    init(startDate: Date, clientId: String?) {
        self.startDate = startDate
        self.endDate = nil
        self.distanceMeters = 0
        self.clientId = clientId
    }
}
