//
//  TripsListViewController.swift
//  Geo-Trax
//
//  Created by Stephen Wall on 4/7/20.
//  Copyright © 2020 syntaks.io. All rights reserved.
//

import UIKit
import CoreData
import MessageUI


class TripsListViewController: UIViewController {
    
    private let context = CoreDataStack().managedObjectContext
    @IBOutlet weak var tableView: UITableView!
    
    lazy var fetchedResultsController: TripFetchedResultsController = {
        return TripFetchedResultsController(managedObjectContext: self.context, tableView: self.tableView)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func deleteAllTrips(_ sender: Any) {
        if let fetchedObjects = fetchedResultsController.fetchedObjects {
            if fetchedObjects.count > 0 {
                presentDeleteAlert()
            }
        }
    }
    
    @IBAction func exportAllTrips(_ sender: Any) {
        //TODO: - Create an excel document to attach to an email?
        let export = createCSVExport()
        if export.count > 0 {
            guard let data = saveAndExport(exportString: export) else { return }
            sendEmailWithCSV(with: data)
        }
    }
    
    private func presentDeleteAlert() {
        let alert = UIAlertController(title: "Delete All Trips?", message: "Are you sure you want to delete ALL of your trips?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action:UIAlertAction!) in
            self.deleteAllTrips()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    private func deleteAllTrips() {
        guard let trips = fetchedResultsController.fetchedObjects else { return }
        for trip in trips {
            context.delete(trip)
        }
        context.saveChanges()
    }
    
    private func createCSVExport() -> String {
        guard let trips = fetchedResultsController.fetchedObjects?.reversed() else { return "" }
        
        var dayTrips: [String : [Trip]] = [String : [Trip]]()
        
        // Sort Trips by day.
        for trip in trips {
            let tripDay = Date.getStartOfDayString(from: trip.startDate)
            if dayTrips[tripDay] != nil {
                // Trips array already exists
                dayTrips[tripDay]!.append(trip)
            } else {
                // Create the new day and add initial trip.
                dayTrips[tripDay] = [trip]
            }
        }
        
        // CSV Export String
        var export: String = "Date, Clients, Miles \n"
        // Create CSV Rows for each day.
        for day in dayTrips {
            var clientString = ""
            var dayMiles = 0.0
            for trip in day.value {
                if trip.clientId.count < 1 {
                    clientString += "Client - "
                } else {
                    clientString += "\(trip.clientId) - "
                }
                
                dayMiles += trip.distanceMiles
            }
            export += "\(day.key), \(clientString), \(dayMiles) \n"
        }
        
        print(export)
        
        return export
    }
    
    func saveAndExport(exportString: String) -> Data? {
        let exportFilePath = NSTemporaryDirectory() + "export.csv"
        let exportFileURL = NSURL(fileURLWithPath: exportFilePath)
        FileManager.default.createFile(atPath: exportFilePath, contents: NSData() as Data, attributes: nil)
        var fileHandle: FileHandle? = nil
        do {
            fileHandle = try FileHandle(forWritingTo: exportFileURL as URL)
        } catch {
            print("Error with fileHandle")
        }

        if fileHandle != nil {
            fileHandle!.seekToEndOfFile()
            let csvData = exportString.data(using: String.Encoding.utf8, allowLossyConversion: false)
            fileHandle!.write(csvData!)
            fileHandle!.closeFile()
            return csvData
        }
        return nil
    }
    
    private func sendEmailWithCSV(with data: Data) {
        if(MFMailComposeViewController.canSendMail() ) {
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            //Set the subject and message of the email
            mailComposer.setSubject("Mileage Data")
            mailComposer.setMessageBody("CSV file attached", isHTML: false)
            //TODO: - Allow user to set default email for compose.
            //mailComposer.setToRecipients(secondaryEmailList)
            mailComposer.addAttachmentData(data, mimeType: "text/csv", fileName: "export")
            self.present(mailComposer, animated: true, completion: nil)
        }
    }
}

extension TripsListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = fetchedResultsController.sections?[section] else { return 0 }
        return section.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TripCell.reuseIdentifier, for: indexPath) as? TripCell else {
            fatalError("Unexpected Index Path")
        }
        return configureCell(cell, at: indexPath)
    }
    
    private func configureCell(_ cell: TripCell, at indexPath: IndexPath) -> TripCell {
        let trip = fetchedResultsController.object(at: indexPath)
        cell.dateLabel.text = Date.getFormattedDate(date: trip.startDate)
        cell.distanceLabel.text = "\(trip.distanceMiles) Miles"
        if trip.clientId.count > 0 {
            cell.clientIdLabel.text = trip.clientId
        }
        cell.durationLabel.text = trip.duration
        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let trip = fetchedResultsController.object(at: indexPath)
        context.delete(trip)
        context.saveChanges()
    }
}

extension TripsListViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}
