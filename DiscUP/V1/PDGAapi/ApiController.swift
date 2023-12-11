//
//  ApiController.swift
//  DiscUP
//
//  Created by Benjamin Tincher on 4/10/21.
//

import Foundation

struct LoginStrings {
    static let sessionID = "sessid"
    static let sessionName = "session_name"
    static let token = "token"
}

struct LoginResponse: Codable {
    let sessid: String
    let session_name: String
    let token: String
}

struct ApiLogin: Codable {
    var username: String
    var password: String
}

class ApiController {
    static let baseURL = URL(string: "https://api.pdga.com")
    static let courseSearchEndPoint = "/services/json/course"
    static let playerSearchEndPoint = "/services/json/players"
    static let eventSearchEndPoint = "/services/json/event"
    static let loginEndPoint = "/services/json/user/login"
    static let logoutEndPoint = "/services/json/user/logout"
    static let usernameKey = "username"
    static let passwordKey = "password"
    static let nodeURL = "https://www.pdga.com/node"
    static let playerURL = "https://www.pdga.com/player"
    static let eventURL = "https://www.pdga.com/tour/event"
    
    static func login(completion: @escaping (Result<LoginResponse, NetworkError>) -> Void) {
        var usernameValue = ""
        var passwordValue = ""
        
        if  let path = Bundle.main.path(forResource: "ApiLogin", ofType: "plist"),
            let xml = FileManager.default.contents(atPath: path),
            let loginDict = try? PropertyListDecoder().decode(ApiLogin.self, from: xml)
        {
            usernameValue = loginDict.username
            passwordValue = loginDict.password
        }
                
        guard let baseURL = baseURL else { return completion(.failure(.invalidURL)) }
        let loginURL = baseURL.appendingPathComponent(loginEndPoint)
        
        let components = URLComponents(url: loginURL, resolvingAgainstBaseURL: true )
        guard let finalURL = components?.url else { return completion(.failure(.invalidURL)) }
        print(finalURL)
        
        var request = URLRequest(url: finalURL)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let dictionary = [usernameKey : usernameValue, passwordKey : passwordValue]
        request.httpBody = try! JSONEncoder().encode(dictionary)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                return completion(.failure(NetworkError.thrownError(error)))
            }
            
            guard let data = data else { return completion(.failure(NetworkError.noData)) }
                        
            do {
                let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                print("SessionID: \(loginResponse.sessid)")
                print("SessionName: \(loginResponse.session_name)")
                print("token: \(loginResponse.token)")
                
                return completion(.success(loginResponse))
                
            } catch {
                print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                return completion(.failure(NetworkError.unableToDecode))
            }
        }.resume()
    }
    
    static func logout(loginResponse: LoginResponse, completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        
        guard let baseURL = baseURL else { return completion(.failure(.invalidURL)) }
        let logoutURL = baseURL.appendingPathComponent(logoutEndPoint)
        
        let components = URLComponents(url: logoutURL, resolvingAgainstBaseURL: true )
        guard let finalURL = components?.url else { return completion(.failure(.invalidURL)) }
        print(finalURL)
        
        var request = URLRequest(url: finalURL)
        request.setValue(loginResponse.token, forHTTPHeaderField: "X-CSRF-Token")
        request.setValue("\(loginResponse.session_name)=\(loginResponse.sessid)", forHTTPHeaderField: "Cookie")
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                return completion(.failure(NetworkError.thrownError(error)))
            }
            
            guard let _ = data else { return completion(.failure(NetworkError.noData)) }
            completion(.success(true))
        }.resume()
    }
    
    static func getEventsBy(eventName: String?, state: String?, startDate: String?, loginResponse: LoginResponse, completion: @escaping (Result<[Event], NetworkError>) -> Void) {
        
        guard let baseURL = baseURL else { return completion(.failure(.invalidURL)) }
        let courseURL = baseURL.appendingPathComponent(eventSearchEndPoint)
        
        var components = URLComponents(url: courseURL, resolvingAgainstBaseURL: true )
        
        var queryItems: [URLQueryItem] = []
        
        if eventName != nil && !eventName!.isEmpty {
            let eventNameQuery = URLQueryItem(name: EventQueryStrings.eventName, value: eventName)
            queryItems.append(eventNameQuery)
        }
        
        if state != nil && !state!.isEmpty {
            let stateQuery = URLQueryItem(name: EventQueryStrings.state, value: state)
            queryItems.append(stateQuery)
        }
        
        if startDate != nil && !startDate!.isEmpty {
            let startDateQuery = URLQueryItem(name: EventQueryStrings.startDate, value: startDate)
            queryItems.append(startDateQuery)
        }
        components?.queryItems = queryItems
        
        guard let finalURL = components?.url else { return completion(.failure(.invalidURL)) }
        print(finalURL)
        
        var request = URLRequest(url: finalURL)
        request.setValue("\(loginResponse.session_name)=\(loginResponse.sessid)", forHTTPHeaderField: "Cookie")
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                return completion(.failure(NetworkError.thrownError(error)))
            }
            
            guard let data = data else { return completion(.failure(NetworkError.noData)) }
            
            do {
                let TL = try JSONDecoder().decode(EventTopLevel.self, from: data)
                let events = TL.events
                return completion(.success(events))
                
            } catch {
                print("***Error*** in Function: \(#function)\n\nError: \(error)\n\nDescription: \(error.localizedDescription)")
                return completion(.failure(NetworkError.unableToDecode))
            }
        }.resume()
    }
}
