//
//  PersistenceManager.swift
//  SophiePhotos
//
//  Created by Harrison Javery on 7/6/24.
//

import Foundation

enum PersistenceManager {
    
    static private let defaults = UserDefaults.standard
    
    enum Keys {
        static let id = "user_id"
        static let key = "key"
    }
    
    static func retrieveID() -> String {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        guard let userID = defaults.data(forKey: Keys.id) else {
            // no user id saved
            let newID = UUID()
            let encodedID = try? encoder.encode(newID)
            defaults.set(encodedID, forKey: Keys.id)
            return newID.uuidString
        }
        //id found
        let decodedID = try! decoder.decode(String.self, from: userID)
        return decodedID
    }
    
    static func retrieveKey() -> Int {
        let key = defaults.integer(forKey: Keys.key)
        return key
    }
    
    static func setKey(key: Int) {
        defaults.set(key, forKey: Keys.key)
    }
}
