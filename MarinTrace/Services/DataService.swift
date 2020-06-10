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
    //static let apiURL = "http://bmaapp.de/api"
    static let apiURL = "http://44.227.83.187/api"
    
    ///The custom cache policy to use for list users
    //https://stackoverflow.com/a/57423326/4777497
    private static var cacheManager: Session? = {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .returnCacheDataElseLoad
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
                cacheManager!.request(apiURL, method: .post, parameters: ListUsersInput(), encoder: JSONParameterEncoder.default, headers: headers).validate().responseDecodable(of: ReturnedContacts.self) { (response) in
                    completion(response.value?.data, response.error)
                    if response.error != nil {
                        logError(error: response.error!)
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
    
    //log error to crashlytics/firebase, use function here so we don't have to import firebase everywhere
    static func logError(error: Error) {
        //add localized description in
        let nsError = error as NSError
        let newError = NSError(domain: nsError.domain, code: nsError.code, userInfo: [NSLocalizedDescriptionKey:nsError.localizedDescription])
        Crashlytics.crashlytics().record(error: newError)
    }
    
}

struct ListUsersInput: Codable {
    let operation = "list_users"
}

//MARK: Data Structures
struct ReportInteractionInput: Codable {
    let operation = "report_interaction"
    let reporter: String
    let targets: [String]
}

struct NotifyRiskInput: Codable {
    let operation = "notify_risk"
    let member: String
    let criteria: [String]
}

struct ReturnedContacts: Decodable {
    let data: [Contact]
    
    enum CodingKeys: String, CodingKey {
        case data = "data"
    }
}
    
struct Contact: Codable {
    let cohort: Int
    let email: String
    let name: String
}
