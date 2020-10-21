//
//  User.swift
//  MarinTrace
//
//  Created by Beck Lorsch on 6/8/20.
//  Copyright © 2020 Marin Trace. All rights reserved.
//

import Foundation
import Auth0

//MARK: User
struct User {
    
    //MARK: Enum for MA/Branson with raw value for DB functions
    enum School: String {
        case MA = "ma"
        case Branson = "branson"
    }
    
    //MARK: User Properties
    static var school: School = .MA //initialize with default MA
    static var firstName = ""
    static var lastName = ""
    static var initials = ""
    static var fullName = ""
    static var email = ""
    
    //MARK: Get User Details
    
    /// Gets the user's details
    /// - Parameters:
    ///  - completion: Completion handlers
    ///  - success: Whether the operation succeeded
    static func getDetails(completion: @escaping(_ success:Bool) -> Void) {
        //get token
        credentialsManager.credentials { (error, creds) in
            guard let credentials = creds else {
                DataService.logError(error: error!)
                completion(false)
                return
            }
            Auth0.authentication().userInfo(withAccessToken: credentials.accessToken!).start { result in
                switch(result) {
                case .success(let profile):
                    
                    //set email
                    email = profile.email!
                    
                    //setup name details
                    fullName = profile.name!
                    if let last = profile.familyName, let first = profile.givenName { //if first and last name, use initials, else just use first initial
                        firstName = first
                        lastName = last
                        initials = String(firstName[firstName.startIndex]) + String(lastName[lastName.startIndex])
                    } else if let last = profile.familyName {
                        lastName = last
                        initials = String(lastName[lastName.startIndex])
                    } else if let first = profile.givenName {
                        firstName = first
                        initials = String(firstName[firstName.startIndex])
                    }
                    
                    //get branson or MA
                    if profile.email?.contains("ma.org") ?? false{
                        school = .MA
                    } else {
                        school = .Branson
                    }
                    
                    completion(true)
                    
                case .failure(let error):
                    completion(false)
                    DataService.logError(error: error)
                }
            }
        }
    }
}
