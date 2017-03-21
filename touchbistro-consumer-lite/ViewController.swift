//
//  ViewController.swift
//  touchbistro-consumer-lite
//
//  Created by Frank Caron on 2017-02-22.
//  Copyright © 2017 Frank Caron. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol HandleMapSearch {
    func dropPinZoomIn(_ placemark:MKPlacemark)
}

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var searchMap: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    var locationManager: CLLocationManager?
    var restaurants = [[ : ]]
    var resultSearchController:UISearchController? = nil
    var selectedPin:MKPlacemark? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager!.delegate = self
        locationManager!.desiredAccuracy = kCLLocationAccuracyBest
        
        //Load restaurants
        self.loadRestuarants()
        self.plotRestaurants()
        
        //Authorize location and get to steppin'
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager!.startUpdatingLocation()
            
            //Set initial position
            mapView.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
        } else {
            locationManager!.requestWhenInUseAuthorization()
        }
        
        //Set up search bar
        self.setupSearch()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        
        switch status {
        case .notDetermined:
            print("NotDetermined")
        case .restricted:
            print("Restricted")
        case .denied:
            print("Denied")
        case .authorizedAlways:
            print("AuthorizedAlways")
        case .authorizedWhenInUse:
            print("AuthorizedWhenInUse")
            locationManager!.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        //Get current location
        let location = locations.first!
        
        //Plot current location
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 100, 100)
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
        locationManager?.stopUpdatingLocation()
        locationManager = nil

    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to initialize GPS: ", error)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Load restaurant data
    func loadRestuarants() {
        restaurants.append(["name": "MyVenue", "lat": 40.00, "lon": 70.00])
        restaurants.append(["name": "MyVenue 2", "lat": 20.00, "lon": 60.00])
    }
 
    //Load restaurant data
    func plotRestaurants() {
        //Plot restaurants
        for restaurant in restaurants {
            if (restaurant["lat"] != nil) {
                let latitude:CLLocationDegrees = restaurant["lat"] as! Double
                let longitude:CLLocationDegrees = restaurant["lon"] as! Double
                let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
                let span:MKCoordinateSpan = MKCoordinateSpanMake(100, 100)
                let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
                mapView.setRegion(region, animated: true)
                let newVenue = MyAnnotation(title: restaurant["name"] as! String, coordinate: location, subtitle: restaurant["name"] as! String);
                mapView.addAnnotation(newVenue);
            }
        }
    }
    
    //Set up search
    func setupSearch() {
        //Set up the search table
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        //Set up the search bar
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        
        //Set properties
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        //Associate search table with map view
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
    }
    
}

extension ViewController: HandleMapSearch {
    func dropPinZoomIn(_ placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = city + ", " + state
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
}

