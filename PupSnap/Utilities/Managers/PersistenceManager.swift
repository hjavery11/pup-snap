//
//  PersistenceManager.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/6/24.
//

import Foundation
import FirebaseMessaging
import FirebaseAuth
import FirebaseRemoteConfigInternal


enum PersistenceManager {
    
    static private let defaults = UserDefaults.standard
    
    enum Keys {
        static let id = "user_id"
        static let key = "key"
        static let dog = "dogPhoto"
        static let dogName = "dog_name"
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
    
    static func setKey(to key:Int) {
        defaults.set(key, forKey: Keys.key)
        
    }
    static func unsetKey() {
        defaults.removeObject(forKey: Keys.key)
    }
    
    static func subscribeToPairingKey(pairingKey: String) async throws {
        let topic = "pairingKey_\(pairingKey)"
        do {
            try await Messaging.messaging().subscribe(toTopic: topic)
            print("Subscribed to topic: \(topic)")
        } catch {
            throw PSError.subscribeError(underlyingError: error)
        }
    }

    static func unsubscribeFromPairingKey() async throws {
        let key = defaults.integer(forKey: Keys.key)
        do {
            try await Messaging.messaging().unsubscribe(fromTopic: "pairingKey_\(key)")
        } catch {
            throw PSError.unsubscribeError(underlyingError: error)
        }
    }
    
    static func launchSetup() async throws {
        let userKey = self.retrieveKey()
        //check if key is 0 which means its a first time launch
        if userKey == 0 {
            let allKeys = try await NetworkManager.shared.retrieveAllKeys()
            guard !allKeys.isEmpty else {
                print("No keys returned from database. Exiting launch")
                return
            }
            //generate new 8-digit int key not in current keys
            var newKey: Int
            repeat {
                newKey = Int.random(in: 10000000...99999999)
            } while allKeys.contains(newKey)
            //save key to user defaults
            self.setKey(to: newKey)
            print("New user key set to :\(newKey)")
            // initalize the key which is a firebase function that creates an empty object in the datbaase so the user has access to it
            try await NetworkManager.shared.initializeKey(pairingKey: newKey)
            try await NetworkManager.shared.setClaims(with: newKey)

            //end of user setup. Should now have claims setup to be able to access database
        } else {
            //returning user
            //let _ = try await Auth.auth().signInAnonymously() commenting out for now tot see if i need to call everytime
        }
    }
    
    static func updateDogPhoto(photo: String) {
        defaults.set(photo, forKey: Keys.dog)
    }
    
    static func getDogPhoto() -> String? {
        defaults.string(forKey: Keys.dog)
    }
    
    static func setDogName(to name: String) {
        defaults.set(name, forKey: Keys.dogName)
    }
    
    static func getDogName() -> String? {
        defaults.string(forKey: Keys.dogName)
    }  
}
