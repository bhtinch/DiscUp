//
//  SearchRangeUnit.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 11/5/22.
//

import Foundation
import CoreLocation

enum SearchRange {
    case miles(Int)
    case kilometers(Int)
    
    var convertToMeters: Int {
        switch self {
        case .miles(let value):         return Int(Measurement(value: Double(value), unit: UnitLength.miles).converted(to: .meters).value)
        case .kilometers(let value):    return value * 1000
        }
    }
    
    var latitudeDegrees: Double {
        convertToLatitudeDegrees(distanceMeters: convertToMeters)
    }
    
    
    var longitudeDegrees: Double {
        convertToLongitudeDegrees(distanceMeters: convertToMeters)
    }
    
    func convertToLatitudeDegrees(distanceMeters: Int) -> Double {
        let searchCenterLocation = Location.userCurrentLocation ?? Location.defaultLocation
        
        let outerLimitCoordinate = searchCenterLocation.coordinate.coordinate(bearingRadiansFromNorth: 0, distanceMeters: Double(distanceMeters))
        
        return abs(outerLimitCoordinate.latitude - searchCenterLocation.latitude)
    }
    
    func convertToLongitudeDegrees(distanceMeters: Int) -> Double {
        let searchCenterLocation = Location.userCurrentLocation ?? Location.defaultLocation
        
        let outerLimitCoordinate = searchCenterLocation.coordinate.coordinate(bearingRadiansFromNorth: (.pi / 2), distanceMeters: Double(distanceMeters))
        
        return abs(outerLimitCoordinate.longitude - searchCenterLocation.longitude)
    }
}
