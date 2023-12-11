//
//  Event.swift
//  PdgaApiTesting
//
//  Created by Benjamin Tincher on 4/6/21.
//

import Foundation

struct EventQueryStrings {
    static let eventName = "event_name"
    static let state = "state"
    static let startDate = "start_date"
}

enum EventProperties: String, CaseIterable {
    case tournament_name = "Event"
    case city = "City"
    case state_prov = "State"
    case country = "Country"
    case start_date = "Start Date"
    case end_date = "End Date"
    case status = "Sanctioned"
    case tier = "Tier"
    case event_url = "Event Link"
    case registration_url = "Registration Link"
}

struct EventTopLevel: Codable {
    let events: [Event]
}

struct Event: Codable {
    var tournament_name: String?
    var city: String?
    var state_prov: String?
    var country: String?
    var start_date: String?
    var end_date: String?
    var status: String?
    var tier: String?
    var event_url: String?
    var registration_url: String?
}

extension Event {
    func propertiesArray() -> [[String]]? {
        var labelDict: [String : String] = [:]
        
        EventProperties.allCases.forEach {
            labelDict.updateValue($0.rawValue, forKey: "\($0)")
        }
        
        let mirror = Mirror(reflecting: self)
        
        var propertiesArray: [[String]] = []
        var propertyArray: [String] = []
        
        mirror.children.forEach {
            propertyArray = []
            
            if $0.label == "tournament_name" {
                // do nothing
            } else if $0.label == "tier" {
                if let labelName = $0.label {
                    if let label = labelDict[labelName] {
                        propertyArray.append(label)
                    }
                    
                    let value = $0.value as? Tier
                    propertyArray.append(value?.rawValue ?? "No Information")
                    
                    propertiesArray.append(propertyArray)
                }
            } else {
                if let labelName = $0.label {
                    if let label = labelDict[labelName] {
                        propertyArray.append(label)
                    }
                    
                    let value = $0.value as? String ?? "No Information"
                    propertyArray.append(value)
                    
                    propertiesArray.append(propertyArray)
                }
            }
        }
        return propertiesArray
    }
    
    func configureStartDate() -> String? {
        guard let startDateString = self.start_date,
              let startDate = startDateString.stringToDate(format: .searchedDate) else { return nil }
        
        let formattedStartDateString = startDate.dateToString(format: .eventDate)
        return formattedStartDateString
    }
}
