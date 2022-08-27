//
//  Location.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 5/17/21.
//

import Foundation
import CoreLocation

class Location {
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
