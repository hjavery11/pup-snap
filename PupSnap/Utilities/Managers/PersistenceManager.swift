//
//  PersistenceManager.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/6/24.
//

import Foundation
import FirebaseMessaging
import FirebaseAuth
import FirebaseRemoteConfig


enum PersistenceManager {
    
    static private let defaults = UserDefaults.standard
    
    enum Keys {
        static let id = "user_id"
        static let key = "key"
        static let dog = "dogPhoto"
        static let dogName = "dog_name"
        static let notification = "notifications"
        static let setupComplete = "setup_complete"
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
    
    static func subscribeToPairingKey(pairingKey: Int) async throws {
        let topic = "pairingKey_\(pairingKey)"
        do {
            try await Messaging.messaging().subscribe(toTopic: topic)
            print("Subscribed to topic: \(topic)")
        } catch {
            throw PSError.subscribeError(underlyingError: error)
        }
    }
    
    static func changeKey(to key: Int) async throws{
        //first set the claims and make sure it works before deleting key
        try await NetworkManager.shared.setClaims(with: key)
        //deleting key and unsubscxribing for pushes
        try await self.unsubscribeFromPairingKey()
        self.unsetKey()
        
        try await LaunchManager.shared.refreshToken()
        
        //now set and subscribe to new key
        try await self.subscribeToPairingKey(pairingKey: key)
        self.setKey(to: key)
    }
    
    static func branchKeySetup(key: Int) async throws {
        try await NetworkManager.shared.setClaims(with: key)
        try await self.subscribeToPairingKey(pairingKey: key)
        self.setKey(to: key)
    }

    static func unsubscribeFromPairingKey() async throws {
        let key = defaults.integer(forKey: Keys.key)
        do {
            try await Messaging.messaging().unsubscribe(fromTopic: "pairingKey_\(key)")
        } catch {
            throw PSError.unsubscribeError(underlyingError: error)
        }
    }
    
    static func getAuthUser() async throws-> User {
        var user: User
        if let currentUser = Auth.auth().currentUser {
            user = currentUser
        } else {
            let authResult = try await Auth.auth().signInAnonymously()
            let newUser = authResult.user
            user = newUser
        }
        return user
    }   
    
    static func enableNotifications() {
        defaults.set(true, forKey: Keys.notification)
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    static func disableNotifications() {
        defaults.set(false, forKey: Keys.notification)
        UIApplication.shared.unregisterForRemoteNotifications()
    }
    
    static func notificationStatus() -> Bool {
        return defaults.bool(forKey: Keys.notification)
    }
    
    static func setupDone() {
        defaults.set(true, forKey: Keys.setupComplete)
    }
    
    static func setupStatus() -> Bool {
        defaults.bool(forKey: Keys.setupComplete)
    }
  
}
