//
//  LocationManager.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 5/17/21.
//

import Combine
import CoreLocation
import GeoFire
import UIKit

class LocationManager: CLLocationManager {
    //  MARK: - Shared
    static let shared = LocationManager()
    
    let geoCoder = CLGeocoder()
    
    //  MARK: - Publishers
    var authStatusChanged = PassthroughSubject<CLAuthorizationStatus, Never>()
    
    //  MARK: - Initialization
    override init() {}
}


//  MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authStatusChanged.send(manager.authorizationStatus)
    }
}


//  MARK: - CLLocationManager Extensions
extension LocationManager {
    func placemark(zip: String) async -> CLPlacemark? {
        guard let placemarks = try? await geoCoder.geocodeAddressString(zip) else { return nil }
        
        return placemarks.first
    }
    
    func coordinate(zip: String) async -> CLLocationCoordinate2D? {
        guard let placemark = try? await placemark(zip: zip) else { return nil }
        
        return placemark.location?.coordinate
    }
    
    func createHash(zip: String) async -> String?  {
        guard let coordinate = await LocationManager.shared.coordinate(zip: zip) else { return nil }
        
        return GFUtils.geoHash(forLocation: coordinate)
    }
    
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
    
    func requestLcoationAuthorization() {
        guard authorizationStatus == .notDetermined else { return }
        
        requestWhenInUseAuthorization()
    }
    
    func confirmAuthorization(_ sender: UIViewController) -> Bool {
        let status = authorizationStatus
        
        switch status {
        case .notDetermined:
            requestWhenInUseAuthorization()
            return false
            
        case .authorizedAlways, .authorizedWhenInUse:
            return true
            
        default:
            Alerts.presentAlertWith(
                title: "Location Services Not Enabled",
                message: "Please update the app permissions in order to use this feature.",
                sender: sender
            )
            
            return false
        }
    }
}
