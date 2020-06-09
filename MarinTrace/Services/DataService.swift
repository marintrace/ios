//
//  DataService.swift
//  MarinTrace
//
//  Created by Beck Lorsch on 6/7/20.
//  Copyright © 2020 Marin Trace. All rights reserved.
//

import Foundation

//MARK: Data Service
struct DataService {
    
    //X-School
    
    //
    /// List all users within school for contact search
    /// - Parameter completion: Completion handler
    /// - Parameter contacts: Array of the school's contacts
    /// - Parameter error: An error
    static func listUsers(completion: @escaping(_ contacts: [Contact]?, _ error: Error?) -> Void) {
        
        
        
    }
    
}

//MARK: DataStructures
struct Contact: Codable {
    let id: String
    let name: String
}
