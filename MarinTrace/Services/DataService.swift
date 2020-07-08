//
//  DataService.swift
//  MarinTrace
//
//  Created by Beck Lorsch on 6/7/20.
//  Copyright © 2020 Marin Trace. All rights reserved.
//

import Foundation
import Firebase
import Alamofire
import FirebaseCrashlytics

//MARK: Data Service
struct DataService {
    
    /// Endpoint for API
    static let apiURL = "https://bmaapp.de/api"
    
    ///The  original cache policy to use for list users (don't use DB if we have a cached versionn)
    //https://stackoverflow.com/a/57423326/4777497
    private static var cache: Session? = {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        let alamofireManager = Session(configuration: configuration)
        return alamofireManager
    }()
    
    ///The  cache policy to use for list users if cache is corrupted; force fetching from DB
    //https://stackoverflow.com/a/57423326/4777497
    private static var databaseOnly: Session? = {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        let alamofireManager = Session(configuration: configuration)
        return alamofireManager
    }()
    
    /// Get headers for HTTP requests
    /// - Parameters:
    ///   - completion: Completion handler callback
    ///   - headers: The  headers
    ///   -  error: An error
    static func getHeaders(completion: @escaping(_ headers: HTTPHeaders?, _ error: Error?) -> Void) {
        //get token
        Auth.auth().currentUser?.getIDToken(completion: { (token, error) in
            if error != nil {
                completion(nil, error)
                if error != nil {
                    logError(error: error!)
                }
            } else {
                let headers: HTTPHeaders = ["Authorization":"Bearer \(token!)", "X-School":User.school.rawValue, "Content-Type":"application/json"]
                completion(headers, nil)
            }
        })
    }
    
    /// List all users within school for contact search
    /// - Parameters:
    ///  - completion: Completion handler callback
    ///  - contacts: Array of the school's contacts
    ///  - error: An error
    static func listUsers(completion: @escaping(_ contacts: [Contact]?, _ error: Error?) -> Void) {
        getHeaders { (headers, error) in
            if error != nil {
                completion(nil, error)
            } else {
                //use cache
                cache!.request(apiURL, method: .post, parameters: ListUsersInput(), encoder: JSONParameterEncoder.default, headers: headers).validate().responseDecodable(of: ReturnedContacts.self) { (response) in
                    
                    //if error couldn't be read (error code 10), cache is somehow corrupted -> fallback on db
                    if let afError = response.error as NSError? {
                        if afError.code == 10 {
                            databaseOnly!.request(apiURL, method: .post, parameters: ListUsersInput(), encoder: JSONParameterEncoder.default, headers: headers).validate().responseDecodable(of: ReturnedContacts.self) { (dbResponse) in
                                completion(dbResponse.value?.data, dbResponse.error)
                                if dbResponse.error != nil {
                                    logError(error: dbResponse.error!)
                                }
                            }
                        }
                    } else {
                        completion(response.value?.data, response.error)
                        if response.error != nil {
                            logError(error: response.error!)
                        }
                    }
                    
                }
            }
        }
    }
    
    /// Report an interaction
    /// - Parameters:
    ///   - targetIDS: The ids (email before @) of the people interacted with
    ///   - completion: Completion handler callback
    ///   -  error: An error
    static func reportInteractions(targetIDS: [String], completion: @escaping(_ error: Error?) -> Void) {
        getHeaders { (headers, error) in
            if error != nil {
                completion(error)
            } else {
                AF.request(apiURL, method: .post, parameters: ReportInteractionInput(reporter: getUserID(), targets: targetIDS), encoder: JSONParameterEncoder.default, headers: headers).validate().response { (response) in
                    completion(response.error)
                    if response.error != nil {
                        logError(error: response.error!)
                    }
                }
            }
        }
    }
    
    /// Notifies server of user's risk. Will report if a positive test, or more than two symptoms
    /// - Parameters:
    ///   -  completion: Completion handler callback
    ///   -  criteria: Criteria for report. Strings will be shown as list to admin in email
    ///   -  error: An error
    static func notifyRisk(criteria: [String], completion: @escaping(_ error: Error?) -> Void) {
        getHeaders { (headers, error) in
            if error != nil {
                completion(error)
            } else {
                AF.request(apiURL, method: .post, parameters: NotifyRiskInput(member: getUserID(), criteria: criteria), encoder: JSONParameterEncoder.default, headers: headers).validate().response { (response) in
                    completion(response.error)
                    if response.error != nil {
                        logError(error: response.error!)
                    }
                }
            }
        }
    }
    
    /// Gets a user's id (email before @)
    /// - Returns: The user id
    static func getUserID() -> String {
        let email = User.email
        let range = email.range(of: "@")
        let id = String(email[..<range!.lowerBound])
        return id
    }
    
    /// Logs error in firebase/crashlytics with domain, code, and localized description
    /// - Parameter error: Error to report
    static func logError(error: Error) {
        //add localized description in
        let nsError = error as NSError
        let newError = NSError(domain: nsError.domain, code: nsError.code, userInfo: [NSLocalizedDescriptionKey:nsError.localizedDescription])
        Crashlytics.crashlytics().record(error: newError)
    }
    
}

//MARK: Data Structures
/// Codable representation of the HTTP body for a list users request
struct ListUsersInput: Codable {
    let operation = "list_users"
}

/// Codable representation of the HTTP body for a report interaction request
struct ReportInteractionInput: Codable {
    let operation = "report_interaction"
    let reporter: String
    let targets: [String]
}

/// Codable representation of the HTTP body for a notify risk request
struct NotifyRiskInput: Codable {
    let operation = "notify_risk"
    let member: String
    let criteria: [String]
}

/// Codable representation of the HTTP result for a list users request
struct ReturnedContacts: Decodable {
    let data: [Contact]
}
    
/// Codable representation of the user/contact data structure used by the app as well as the database
struct Contact: Codable {
    let cohort: Int
    let email: String
    let name: String
}
