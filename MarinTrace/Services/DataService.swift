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

//MARK: Data Service
struct DataService {
    
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
            } else {
                let headers: HTTPHeaders = ["Authorization":"Bearer \(token!)", "X-School":User.school.rawValue]
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
                AF.request("", method: .get, parameters: ["operation":"list_users"], headers: headers).responseDecodable(of: [Contact].self) { (response) in
                    completion(response.value, response.error)
                }
            }
        }
    }
    
    /// Report an interaction
    /// - Parameters:
    ///   - personBID: The id (email before @) of the person interacted with
    ///   - completion: Completion handler callback
    ///   -  error: An error
    static func reportInteraction(personBID: String, completion: @escaping(_ error: Error?) -> Void) {
        getHeaders { (headers, error) in
            if error != nil {
                completion(error)
            } else {
                let email = User.email
                let range = email.range(of: "@")
                let personAID = String(email[..<range!.lowerBound]) //get this user's id as email before @
                AF.request("", method: .post, parameters: ReportInteractionInput(memberA: getUserID(), memberB: personBID), headers: headers).response { (response) in
                    completion(response.error)
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
                 //get this user's id as email before @
                AF.request("", method: .post, parameters: NotifyRiskInput(member: getUserID(), criteria: criteria), headers: headers).response { (response) in
                    completion(response.error)
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
    
    //if positive diagnoses or 2+ symptoms
    //operation: notify_risk
    //member: id
    //criteria: ["Positive Test"] or ["Loss of smell/taste"]
    
}

//MARK: Data Structures
struct ReportInteractionInput: Codable {
    let operation = "report_interaction"
    let memberA: String
    let memberB: String
}

struct NotifyRiskInput: Codable {
    let operation = "notify_risk"
    let member: String
    let criteria: [String]
}
    
struct Contact: Codable {
    let id: String
    let name: String
}
