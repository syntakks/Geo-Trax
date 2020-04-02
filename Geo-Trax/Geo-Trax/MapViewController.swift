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

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var centerButton: UIButton!
    @IBOutlet weak var optionsButton: UIButton!
    
    var currentLocation: CLLocation? = nil
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 500
    var isPanning = false
    
//MARK: - View Controller Delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
        checkLocationServices()
    }
    
    func setupButtons() {
        centerButton.layer.shadowColor = UIColor.black.cgColor
        centerButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        centerButton.layer.masksToBounds = false
        centerButton.layer.shadowRadius = 1.0
        centerButton.layer.shadowOpacity = 0.5
        centerButton.layer.cornerRadius = centerButton.frame.width / 2
        
        optionsButton.layer.shadowColor = UIColor.black.cgColor
        optionsButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        optionsButton.layer.masksToBounds = false
        optionsButton.layer.shadowRadius = 1.0
        optionsButton.layer.shadowOpacity = 0.5
        optionsButton.layer.cornerRadius = centerButton.frame.width / 2
    }
    
    @IBAction func didPressCenterButton(_ sender: Any) {
        isPanning = false
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
        locationManager.startUpdatingLocation()
    }
    
    func isUserPanning() -> Bool {
        let view = self.mapView.subviews[0]
        //  Look through gesture recognizers to determine whether this region change is from user interaction
        if let gestureRecognizers = view.gestureRecognizers {
            for recognizer in gestureRecognizers {
                if( recognizer.state == UIGestureRecognizer.State.began ||
                    recognizer.state == UIGestureRecognizer.State.ended ) {
                    return true
                }
            }
        }
        return false
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
        print("Location Coordinate: \(String(describing: locations.last?.coordinate))")
        if isPanning { return }
        guard let location = locations.last else { return }
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: true)
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

