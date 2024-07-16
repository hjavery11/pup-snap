//
//  PersistenceManager.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/6/24.
//

import Foundation
import FirebaseMessaging


enum PersistenceManager {
    
    static private let defaults = UserDefaults.standard
    
    enum Keys {
        static let id = "user_id"
        static let key = "key"
        static let dog = "dogPhoto"
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
        Task {
            do {
                try await unsubscribeFromPairingKey()
                defaults.set(key, forKey: Keys.key)
                subscribeToPairingKey(pairingKey: String(key))
            } catch {
                print("Error unsubscribing from pairing key with error: \(error.localizedDescription)")
            }
        }
    }
    
    static func subscribeToPairingKey(pairingKey: String) {
        let topic = "pairingKey_\(pairingKey)"
        Messaging.messaging().subscribe(toTopic: topic) { error in
            if let error=error {
                print("Error subscribign to topic: \(error)")
            }else {
                print("Subscribed to topic: \(topic)")
            }
        }
    }
    
    static func unsubscribeFromPairingKey() async throws {
        let key = defaults.integer(forKey: Keys.key)
        try await Messaging.messaging().unsubscribe(fromTopic: "pairingKey_\(key)")
    }
    
    static func updateDogPhoto(photo: String) {
        defaults.set(photo, forKey: Keys.dog)
    }
    
    static func getDogPhoto() -> String? {
        defaults.string(forKey: Keys.dog)
    }
}
