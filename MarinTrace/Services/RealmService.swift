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
    
    /// Gets the realm DB
    /// - Returns: The realm
    static func getRealm() -> Realm {
        //get encryption key from keychain
        let config = Realm.Configuration(encryptionKey: getKey() as Data)
        let realm = try! Realm(configuration: config)
        return realm
    }
    
    /// Logs an item to the backup
    /// - Parameter data: The log to backup
    static func logItem(data: String) {
        let realm = getRealm()
        let entry = BackupEntry()
        entry.data = data
        try! realm.write {
            realm.add(entry)
        }
    }
    
    /// Lists backed up items
    /// - Returns: The items
    static func listItems() -> [BackupEntry] {
        let realm = getRealm()
        let items = realm.objects(BackupEntry.self).sorted() {$0.date > $1.date} //sort recent first
        return items
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
}
