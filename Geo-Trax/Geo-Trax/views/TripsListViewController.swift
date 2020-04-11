//
//  TripsListViewController.swift
//  Geo-Trax
//
//  Created by Stephen Wall on 4/7/20.
//  Copyright © 2020 syntaks.io. All rights reserved.
//

import UIKit
import CoreData

class TripsListViewController: UIViewController {
    
    private let context = CoreDataStack().managedObjectContext
    @IBOutlet weak var tableView: UITableView!
    var trips = [Trip]() {
        didSet{
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let request: NSFetchRequest<Trip> = Trip.fetchRequest()
        do {
            trips = try context.fetch(request)
        } catch {
            print("Error fetching Trip Objects: \(error.localizedDescription)")
        }
    }
}

extension TripsListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TripCell.reuseIdentifier, for: indexPath) as? TripCell else {
            fatalError("Unexpected Index Path")
        }
        let trip = trips[indexPath.row]
        cell.dateLabel.text = Date.getFormattedDate(date: trip.startDate)
        cell.distanceLabel.text = "\(trip.distanceMiles) Miles"
        return cell
    }
    
}
