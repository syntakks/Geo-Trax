//
//  Trip.swift
//  Geo-Trax
//
//  Created by Stephen Wall on 4/6/20.
//  Copyright © 2020 syntaks.io. All rights reserved.
//

import Foundation

class Trip {
    var clientId: String?
    let startDate: Date
    let endDate: Date?
    var duration: Double {
        if let end = endDate {
            return startDate.distance(to: end)
        }
        return 0
    }
    var distance: Double
    
    init(startDate: Date, clientId: String?) {
        self.startDate = startDate
        self.endDate = nil
        self.distance = 0
        self.clientId = clientId
    }
}
