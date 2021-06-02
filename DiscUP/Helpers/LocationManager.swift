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
    init() {}
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
    
    func getPlacemarkFrom(location: Location, completionHandler: @escaping (CLPlacemark?) -> Void ) {
        let geocoder = CLGeocoder()
        
        let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        // Look up the location and pass it to the completion handler
        geocoder.reverseGeocodeLocation(clLocation, completionHandler: { (placemarks, error) in
            if error == nil {
                let firstLocation = placemarks?[0]
                completionHandler(firstLocation)
            }
            else {
                // An error occurred during geocoding.
                completionHandler(nil)
            }
        })
    }
}   //  End of Extension
