//
//  User.swift
//  MarinTrace
//
//  Created by Beck Lorsch on 6/8/20.
//  Copyright © 2020 Marin Trace. All rights reserved.
//

import Foundation
import Firebase

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
    static func getDetails() {
        
        guard let user = Auth.auth().currentUser else {return}
        email = user.email!
        
        //setup name details
        guard let name = user.displayName else {return}
        fullName = name
        let namesSplit = name.components(separatedBy: " ")
        if namesSplit.count > 1 { //if first and last name, use initials, else just use first initial
            firstName = namesSplit[0]
            lastName = namesSplit[1]
            initials = String(firstName[firstName.startIndex]) + String(lastName[lastName.startIndex])
        } else {
            firstName = namesSplit[0]
            initials = String(firstName[firstName.startIndex])
        }
        
        //get branson or MA
        if user.email?.contains("ma.org") ?? true {
            school = .MA
        } else {
            school = .Branson
        }
        
    }
    
}
