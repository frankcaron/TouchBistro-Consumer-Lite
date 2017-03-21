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

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var searchMap: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    var locationManager: CLLocationManager?
    var restaurants = [[ : ]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager!.delegate = self
        
        //Load restaurants
        self.loadRestuarants()
        self.plotRestaurants()
        
        //Authorize location and get to steppin'
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager!.startUpdatingLocation()
            mapView.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
        } else {
            locationManager!.requestWhenInUseAuthorization()
        }
        
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        
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
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        //Get current location
        let location = locations.first!
        
        //Plot current location
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 0.2, 0.2)
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
        locationManager?.stopUpdatingLocation()
        locationManager = nil

    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Failed to initialize GPS: ", error.description)
        
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
                let span:MKCoordinateSpan = MKCoordinateSpanMake(20, 20)
                let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
                //mapView.setRegion(region, animated: true)
                let newVenue = MyAnnotation(title: restaurant["name"] as! String, coordinate: location, subtitle: restaurant["name"] as! String);
                mapView.addAnnotation(newVenue);
            }
        }
    }

}

