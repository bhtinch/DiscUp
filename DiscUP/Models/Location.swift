//
//  Location.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 5/17/21.
//

import Foundation
import CoreLocation
import CloudKit

class Location {
    /// user current location if location services are granted, otherwise returns nil
    static var userCurrentLocation: Location? {
        guard let coordinate = LocationManager.shared.location?.coordinate else { return nil }
        
        return Location(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
    
    /// defaultLocation is Emporia, KS
    static let defaultLocation: Location = Location(latitude: 38.404, longitude: -96.182)
    
    /// unknown location defined as 0 lat and 0 long
    static let unknownLocation = Location(latitude: 0, longitude: 0)
    
    let latitude: Double
    let longitude: Double
    var city: String = ""
    var state: String = ""
    var zipCode: String = ""
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
        
        setGeoValues()
    }
}

extension Location {
    private func setGeoValues() {
        let clLocation = CLLocation(latitude: latitude, longitude: longitude)
        
        CLGeocoder().reverseGeocodeLocation(clLocation) { [weak self] placemarks, _ in
            self?.zipCode = placemarks?.first?.postalCode ?? ""
            self?.city = placemarks?.first?.locality ?? ""
            self?.state = placemarks?.first?.administrativeArea ?? ""
        }
    }
}
