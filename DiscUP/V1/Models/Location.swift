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
    
    //  MARK: - Static Properties
    
    /// user current location if location services are granted, otherwise returns nil
    static var userCurrentLocation: Location? {
        guard let coordinate = LocationManager.shared.location?.coordinate else { return nil }
        
        return Location(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
    
    /// defaultLocation is Emporia, KS
    static let defaultLocation: Location = Location(latitude: 38.404, longitude: -96.182)
    
    /// unknown location defined as 0 lat and 0 long
    static let unknownLocation = Location(latitude: 0, longitude: 0)
    
    static var defaultSellingLocation: Location? {
        guard
            let defaultLat = Default.defaultSellingLocationLat.value as? Double,
            let defaultLong = Default.defaultSellingLocationLong.value as? Double
        else { return nil }
        
        return Location(latitude: defaultLat, longitude: defaultLong)
    }
    
    //  MARK: - Internal Properties
    
    let latitude: Double
    let longitude: Double
    var city: String = ""
    var state: String = ""
    var zipCode: String = ""
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    //  MARK: - Initialization
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
        
        setGeoValues()
    }
}

//  MARK: - Private Methods

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
