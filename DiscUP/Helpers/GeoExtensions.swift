//
//  GeoExtensions.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 11/5/22.
//

import MapKit

extension CLLocationCoordinate2D {
    func coordinate(bearingRadiansFromNorth: Double, distanceMeters: Double) -> CLLocationCoordinate2D {
        let startLatRad = Double(self.latitude * .pi / 180)
        let startLongRad = Double(self.longitude * .pi / 180)
        
        let earthRadiusMeters = 6378100
        let distancePercent = distanceMeters / Double(earthRadiusMeters)
        
        let resultLatRad = asin(sin(startLatRad) * cos(distancePercent) + cos(startLatRad) * sin(distancePercent) * cos(bearingRadiansFromNorth))
        
        let resultLongRad = startLongRad + atan2(sin(bearingRadiansFromNorth) * sin(distancePercent) * cos(startLatRad),
                                                 cos(distancePercent) - sin(startLatRad) * sin(resultLatRad))
        
        return CLLocationCoordinate2D(latitude: resultLatRad * 180 / .pi, longitude: resultLongRad * 180 / .pi)
    }
}
