//
//  RealmService.swift
//  MarinTrace
//
//  Created by Beck Lorsch on 9/24/20.
//  Copyright © 2020 Marin Trace. All rights reserved.
//

import Foundation
import RealmSwift

struct RealmHelper {
    
    /// Gets the realm DB. Can throw error.
    /// - Returns: The realm
    static func getRealm() throws -> Realm  {
        //get encryption key from keychain
        let config = Realm.Configuration(encryptionKey: getKey() as Data, schemaVersion: 4) { (migration, oldSchemaVersion) in //migrate
            if oldSchemaVersion < 4 { //set rawReport to nil for old data
                //only added new property, realm will automatially set to nil so no action required
            }
        }
        do {
            let realm = try Realm(configuration: config)
            return realm
        } catch let error as NSError {
            throw error //TODO - if error bc corrupted realm, delete db and make new one
        }
        
    }
    
    /// Logs an item to the backup
    /// - Parameter data: The log to backup
    static func logItem(data: String, rawReport: RawReports) {
        do {
            let realm = try getRealm()
            let entry = BackupEntry()
            entry.data = data
            entry.rawReport = rawReport
            try realm.write {
                realm.add(entry)
            }
        } catch let error as NSError {
            DataService.logError(error: error)
            AlertHelperFunctions.presentAlert(title: "Your report has been recieved by the server, but we couldn't backup it up on your device", message: error.localizedDescription)
        }
    }
    
    /// Lists backed up items
    /// - Returns: The items
    static func listItems() -> [BackupEntry] {
        do {
            let realm = try getRealm()
            let items = realm.objects(BackupEntry.self).sorted() {$0.date > $1.date} //sort recent first
            return items
        } catch let error as NSError {
            DataService.logError(error: error)
            AlertHelperFunctions.presentAlert(title: "Error going through local backups.", message: error.localizedDescription)
            return [] //fall back on db
        }
    }
    
    /// Lists reports within the last five minutes for status card caching
    /// - Returns: The items
    static func listItemsWithinFiveMinutes() -> [BackupEntry] {
        let date = Calendar.current.date(byAdding: .minute, value: -5, to: Date())
        
        do {
            let realm = try getRealm()
            let items = realm.objects(BackupEntry.self).filter("date >= %@", date!).sorted() {$0.date > $1.date} //sort recent first
            return items
        } catch let error as NSError {
            DataService.logError(error: error)
            AlertHelperFunctions.presentAlert(title: "Couldn't search local backups. Trying server now.", message: error.localizedDescription)
            return [] //fall back on db
        }
    }
    
    /// Gets the Realm encryption key
    /// – from https://github.com/realm/realm-cocoa/tree/master/examples/ios/swift/Encryption
    /// - Returns: The user's Realm encryption key
    static func getKey() -> NSData {
        // Identifier for our keychain entry - should be unique for your application
        let keychainIdentifier = "com.marintrace.realm_key"
        let keychainIdentifierData = keychainIdentifier.data(using: String.Encoding.utf8, allowLossyConversion: false)!

        // First check in the keychain for an existing key
        var query: [NSString: AnyObject] = [
            kSecClass: kSecClassKey,
            kSecAttrApplicationTag: keychainIdentifierData as AnyObject,
            kSecAttrKeySizeInBits: 512 as AnyObject,
            kSecReturnData: true as AnyObject
        ]

        // To avoid Swift optimization bug, should use withUnsafeMutablePointer() function to retrieve the keychain item
        // See also: http://stackoverflow.com/questions/24145838/querying-ios-keychain-using-swift/27721328#27721328
        var dataTypeRef: AnyObject?
        var status = withUnsafeMutablePointer(to: &dataTypeRef) { SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0)) }
        if status == errSecSuccess {
            return dataTypeRef as! NSData
        }

        // No pre-existing key from this application, so generate a new one
        let keyData = NSMutableData(length: 64)!
        let result = SecRandomCopyBytes(kSecRandomDefault, 64, keyData.mutableBytes.bindMemory(to: UInt8.self, capacity: 64))
        assert(result == 0, "Failed to get random bytes")

        // Store the key in the keychain
        query = [
            kSecClass: kSecClassKey,
            kSecAttrApplicationTag: keychainIdentifierData as AnyObject,
            kSecAttrKeySizeInBits: 512 as AnyObject,
            kSecValueData: keyData
        ]

        status = SecItemAdd(query as CFDictionary, nil)
        assert(status == errSecSuccess, "Failed to insert the new key in the keychain")

        return keyData
    }
}

class BackupEntry: Object {
    @objc dynamic var data = ""
    @objc dynamic var date = Date()
    @objc dynamic var rawReport: RawReports? = nil
}

//use option type for polymorphic relationship because realm doesn't support
class RawReports: Object {
    @objc dynamic var dailyReport: DailyReport? = nil
    @objc dynamic var testReport: TestReport? = nil
    @objc dynamic var contactReport: ContactReport? = nil
}

class DailyReport: Object {
    @objc dynamic var numberOfSymptoms = 0
    @objc dynamic var proximity = false
    @objc dynamic var travel = false
}

class TestReport: Object {
    @objc dynamic var type = "negative" //realm doesn't support enums
}

class ContactReport: Object {
    var targets = List<String>() //realm doesn't support arrays
}






