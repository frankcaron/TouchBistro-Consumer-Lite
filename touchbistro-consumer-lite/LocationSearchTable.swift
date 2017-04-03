//
//  LocationSearchTable.swift
//  MapKitTutorial
//
//  Created by Robert Chen on 12/28/15.
//  Copyright © 2015 Thorn Technologies. All rights reserved.
//

import UIKit
import MapKit

class LocationSearchTable : UITableViewController {
    var matchingItems:[MKAnnotation] = []
    var mapView: MKMapView? = nil
    var handleMapSearchDelegate:HandleMapSearch? = nil
    var originalAnnotations:[MKAnnotation] = []
    var firstTime = true
    
    func parseAddress(_ selectedItem:MKPlacemark) -> String {
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
}

extension LocationSearchTable : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let mapView = mapView,
            let searchBarText = searchController.searchBar.text else { return }
        
        /* Use local search request
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                return
            }
            self.matchingItems = response.mapItems
        */
        
        //Filter annotations
        if (firstTime) {
            originalAnnotations = mapView.annotations
            firstTime = false;
        } else {
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotations(originalAnnotations)
        }
        
        let resultPredicate = NSPredicate(format: "SELF like[c] %@", searchBarText)
        print("SearchBarText: " + searchBarText)
        //let filteredAnnotations = mapView.annotations.filter { ($0.title != nil) && (resultPredicate.evaluate(with:$0.title) || isEqual(searchBarText)) }
        let filteredAnnotations = mapView.annotations.filter {annotation in
            return (annotation.title??.localizedCaseInsensitiveContains(searchBarText) ?? false) ||
                (annotation.subtitle??.localizedCaseInsensitiveContains(searchBarText) ?? false)
        }
        
        print("filteredAnnotations: " + String(filteredAnnotations.count))
        
        if (searchBarText != "") {
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotations(filteredAnnotations)
            self.matchingItems = filteredAnnotations
        }
        
        self.tableView.reloadData()
        
    }
}

extension LocationSearchTable {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
      /*
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
     
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let selectedItem = matchingItems[indexPath.row]
        cell.textLabel?.text = selectedItem.title!
        cell.detailTextLabel?.text = selectedItem.subtitle!
        return cell
 
    } */
}

extension LocationSearchTable {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[indexPath.row]
        let destination = MKPlacemark(coordinate: selectedItem.coordinate)
        handleMapSearchDelegate?.dropPinZoomIn(destination)
        dismiss(animated: true, completion: nil)
    }
}
