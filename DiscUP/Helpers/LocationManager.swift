//
//  LocationManager.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 5/17/21.
//

import Foundation
import CoreLocation

class LocationManager {
    static let shared = CLLocationManager()
    private init() {}
}

extension CLLocationManager {
    public func getCoordinates(zipCode: String, completion: @escaping(Result<CLLocationCoordinate2D, Error>) -> Void ) {
        
        
        
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(zipCode) { placemarks, error in
            if error == nil {
                if let placemark = placemarks?.first {
                    let location = placemark.location!
                    
                    return completion(.success(location.coordinate))
                }
            }
            
            completion(.failure(error!))
        }
    }
}   //  End of Extension
