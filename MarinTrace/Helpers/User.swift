//
//  User.swift
//  MarinTrace
//
//  Created by Beck Lorsch on 6/8/20.
//  Copyright © 2020 The MarinTrace Foundation. All rights reserved.
//

import Foundation
import Auth0
import JWTDecode

//MARK: User
struct User {
    
    //MARK: Enum for MA/Branson with raw value for DB functions
    enum School: String {
        case MA = "ma"
        case Branson = "branson"
        case Headlands = "headlands"
        case TildenAlbany = "tilden-albany"
        case TildenWalnutCreek = "tilden-walnut-creek"
        case BransonSummer = "branson-summer"
        case NGS = "ngs"
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
        DataService.logMessage(message: "getting creds for user info")
        credentialsManager.credentials { (error, creds) in
            guard let credentials = creds else {
                DataService.logError(error: error!)
                completion(false)
                return
            }
            DataService.logMessage(message: "getting user info")
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
                    
                    //if initials are empty, then try to pull from full name
                    if initials.isEmpty {
                        let chunks = fullName.split(separator: " ")
                        for name in chunks.prefix(2) {
                            initials += String(name[name.startIndex])
                        }
                    }
                    
                    //get school by decoding token claims
                    guard let jwt = try? decode(jwt: credentials.accessToken!), let roles = jwt.claim(name: "http://marintracingapp.org/role").array else {completion(true); return}
                    if roles.contains("marinacademy") {
                        school = .MA
                    } else if roles.contains("branson") {
                        school = .Branson
                    } else if roles.contains("headlands") {
                        school = .Headlands
                    } else if roles.contains("tilden-albany") {
                        school = .TildenAlbany
                    } else if roles.contains("tilden-walnut-creek") {
                        school = .TildenWalnutCreek
                    } else if roles.contains("branson-summer") {
                        school = .BransonSummer
                    } else if roles.contains("ngs") {
                        school = .NGS
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
