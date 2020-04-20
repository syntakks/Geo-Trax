//
//  ViewController.swift
//  Geo-Trax
//
//  Created by Stephen Wall on 4/1/20.
//  Copyright © 2020 syntaks.io. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
// Core Data
    private let context = CoreDataStack().managedObjectContext
    
//Outlets
    @IBOutlet weak var bannerView: UIView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tripsListButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var centerButton: UIButton!
    @IBOutlet weak var newTripButton: UIButton!
    
// Upper button constraints
    @IBOutlet weak var listButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var settingsButtonTopConstraint: NSLayoutConstraint!
    
// Location Variables
    var previousLocation: CLLocation? = nil
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 100
    var isPanning = false
// Trip
    var currentTrip: TripData?
    var isRecordingTrip: Bool = false
    
//MARK: - View Controller Delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
        checkLocationServices()
        slideBanner()
    }
    
    func setupButtons() {
        tripsListButton.layer.shadowColor = UIColor.black.cgColor
        tripsListButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        tripsListButton.layer.masksToBounds = false
        tripsListButton.layer.shadowRadius = 1.0
        tripsListButton.layer.shadowOpacity = 0.5
        tripsListButton.layer.cornerRadius = centerButton.frame.width / 2
        
        settingsButton.layer.shadowColor = UIColor.black.cgColor
        settingsButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        settingsButton.layer.masksToBounds = false
        settingsButton.layer.shadowRadius = 1.0
        settingsButton.layer.shadowOpacity = 0.5
        settingsButton.layer.cornerRadius = centerButton.frame.width / 2
        
        newTripButton.layer.shadowColor = UIColor.black.cgColor
        newTripButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        newTripButton.layer.masksToBounds = false
        newTripButton.layer.shadowRadius = 1.0
        newTripButton.layer.shadowOpacity = 0.5
        newTripButton.layer.cornerRadius = centerButton.frame.width / 2
        
        centerButton.layer.shadowColor = UIColor.black.cgColor
        centerButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        centerButton.layer.masksToBounds = false
        centerButton.layer.shadowRadius = 1.0
        centerButton.layer.shadowOpacity = 0.5
        centerButton.layer.cornerRadius = centerButton.frame.width / 2
    }

//MARK: - Button Press Events
    @IBAction func didPressSettingsButton(_ sender: Any) {
        
    }
    
    @IBAction func didPressNewTripButton(_ sender: Any) {
        if isRecordingTrip {
            presentSaveAlert()
        } else {
            performSegue(withIdentifier: "newTripSegue", sender: nil)
        }
    }
    
    private func presentSaveAlert() {
        let alert = UIAlertController(title: "End Trip?", message: "Would you like to save your trip and stop tracking milage?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action:UIAlertAction!) in
            self.saveTrip()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    private func saveTrip() {
        print("SAVE TRIP")
        isRecordingTrip = false
        slideBanner()
        slideUpperButtons()
        setNewTripButtonState()
        if let currentTrip = currentTrip {
            currentTrip.endDate = Date()
            let trip = Trip(entity: Trip.entity(), insertInto: context)
            trip.startDate = currentTrip.startDate
            trip.endDate = currentTrip.endDate!
            trip.distanceMeters = currentTrip.distanceMeters
            trip.clientId = currentTrip.clientId ?? ""
            context.saveChanges()
        }
    }
    
    @IBAction func didPressCenterButton(_ sender: Any) {
           isPanning = false
           mapView.userTrackingMode = .follow
    }
    
    //MARK: - Location Methods
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            // Setup our location manager.
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            //TODO:  Show alert letting the user know they have to turn this on.
        }
    }
    
    func checkLocationAuthorization() {
        //This will need always so it can keep tracking milage in the background.
        switch CLLocationManager.authorizationStatus(){
        case .authorizedAlways,
             .authorizedWhenInUse:
            startMapView()
            break
        case .restricted:
            // Parental Controls, show an alert.
            break
        case .notDetermined:
            // Havent picked, so request permission
            locationManager.requestAlwaysAuthorization()
            break
        case .denied:
            // Show alert/ deep link to permissions.
            break
        @unknown default:
            fatalError()
        }
    }
    
    func showUserLocation() {
        // You can set this directly on the MapView in the storyboard.
        mapView.showsUserLocation = true
    }
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = getRegion(center: location)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func getRegion(center: CLLocationCoordinate2D) -> MKCoordinateRegion {
        return MKCoordinateRegion(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
    }
    
    func startMapView() {
        showUserLocation()
        centerViewOnUserLocation()
        mapView.userTrackingMode = .follow
        locationManager.startUpdatingLocation()
    }
    
    func isUserPanning() -> Bool {
        let view = self.mapView.subviews[0]
        //  Look through gesture recognizers to determine whether this region change is from user interaction
        if let gestureRecognizers = view.gestureRecognizers {
            for recognizer in gestureRecognizers {
                if( recognizer.state == UIGestureRecognizer.State.began ||
                    recognizer.state == UIGestureRecognizer.State.ended ) {
                    mapView.userTrackingMode = .none
                    return true
                }
            }
        }
        return false
    }
    
    
//MARK: - Record Trip
    func startNewTrip(trip: TripData) {
        previousLocation = nil
        currentTrip = trip
        distanceLabel.text = "0.0 Miles"
        isRecordingTrip = true
        slideBanner()
        slideUpperButtons()
        setNewTripButtonState()
    }
        
    func slideBanner() {
        UIView.animate(withDuration: 1, animations: {
            if self.isRecordingTrip {
                // Slide it out.
                self.bannerView.transform = CGAffineTransform(translationX: 0, y: 0)
            } else {
                // Slide it in.
                self.bannerView.transform = CGAffineTransform(translationX: 0, y: -130)

            }
        }) { (Bool) in
            if (self.bannerView.isHidden) {
                self.bannerView.isHidden = false
            }
        }
    }
    
    func slideUpperButtons() {
        UIView.animate(withDuration: 1, animations: {
            if self.isRecordingTrip {
                // Slide it out.
                self.tripsListButton.transform = CGAffineTransform(translationX: 0, y: 94)
                self.settingsButton.transform = CGAffineTransform(translationX: 0, y: 94)
            } else {
                // Slide it in.
                self.tripsListButton.transform = .identity
                self.settingsButton.transform = .identity
            }
        }) { (Bool) in
            
        }
    }
    
    func setNewTripButtonState() {
        if isRecordingTrip {
            UIView.animate(withDuration: 1.0) {
                self.newTripButton.backgroundColor = .red
                self.newTripButton.setImage(UIImage(systemName: "stop"), for: .normal)
                self.newTripButton.transform = CGAffineTransform(translationX: 0, y: -10)
                self.newTripButton.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
            }
        } else {
            UIView.animate(withDuration: 1.0) {
                self.newTripButton.backgroundColor = .systemGreen
                self.newTripButton.setImage(UIImage(systemName: "plus"), for: .normal)
                self.newTripButton.transform = .identity
            }
        }
    }

    
}

//MARK: - Distance Helper
extension CLLocationCoordinate2D {
    // Distance in meters
    func distance(to: CLLocationCoordinate2D) -> CLLocationDistance {
        let origin = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let destination = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return destination.distance(from: origin)
    }
}

//MARK: - MapKit Delegates

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("MAP: Coordinate: Lat:\(String(describing: locations.last?.coordinate.latitude)) Long: \(String(describing: locations.last?.coordinate.longitude))")
        if isPanning { return }
        guard let location = locations.last else { return }
        if previousLocation == nil {
            previousLocation = location
        } else {
            guard let latestLocation = locations.last else { return }
            if let distanceInMeters = previousLocation?.distance(from: latestLocation) {
                print("MAP: Distance (meters): \(distanceInMeters)")
                print("MAP: Speed: \(latestLocation.speed * 2.236936) MPH")
                print("MAP:======================================================================")
                if let trip = currentTrip {
                    if isRecordingTrip {
                        trip.distanceMeters += distanceInMeters
                        distanceLabel.text = "\(trip.distanceMiles) Miles"
                        print("TRIP: Client: \(String(describing: trip.clientId))")
                        print("TRIP: Start: \(trip.startDate)")
                        print("TRIP: New Distance: \(distanceInMeters)")
                        print("TRIP: Total Distance: \(trip.distanceMeters) Meters")
                        print("TRIP:======================================================================")
                    }
                }
                
            }
            previousLocation = latestLocation
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        if isPanning { return }
        if isUserPanning() {
            isPanning = true
        }
    }
}

