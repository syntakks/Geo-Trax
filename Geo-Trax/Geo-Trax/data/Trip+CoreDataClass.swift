//
//  Trip+CoreDataClass.swift
//  Geo-Trax
//
//  Created by Stephen Wall on 4/7/20.
//  Copyright © 2020 syntaks.io. All rights reserved.
//
//

import Foundation
import CoreData

public class Trip: NSManagedObject {
    var duration: Double {
        return startDate.distance(to: endDate)
    }
    
    var distanceMiles: Double {
        return (distanceMeters * 0.000621371).truncate(places: 3)
    }
}
