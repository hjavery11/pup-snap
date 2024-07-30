//
//  NetworkManager.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/2/24.
//

import UIKit
import FirebaseStorage
import FirebaseFunctions
import FirebaseAuth
import FirebaseCrashlytics

class NetworkManager {
    static let shared = NetworkManager()
    private let storageHelper = StorageHelper()
    private let dbHelper = DatabaseHelper()
    private let functions = Functions.functions()

    private init() {}

    func fetchCompletePhotos() async throws -> [Photo] {
        let userKey = PersistenceManager.retrieveKey()
        let initialPhotos = try await dbHelper.fetchPhotos(for: userKey)
     
        return initialPhotos.sorted()
    }
    
    func uploadPhoto(photo: Photo, progressHandler: @escaping (Double) -> Void, successHandler: @escaping () -> Void, failureHandler: @escaping (Error) -> Void) -> StorageUploadTask? {
        return storageHelper.uploadImage(photo: photo, progressHandler: progressHandler, successHandler: successHandler, failureHandler: failureHandler)
    }
    
    func checkPhotoLimit() async throws -> Bool {
        return try await dbHelper.checkPhotoLimit()
    }
    
    func updatePhotoRating(photo: Photo) async throws {
        try await dbHelper.editPhotoRating(photo: photo)
    }
  

    func deletePhoto(photo: Photo, last: Bool) async throws {
        do {
            try await dbHelper.deletePhotoFromDB(photo: photo, last: last)
            try await storageHelper.deleteImage(id: photo.id)
            print("deleted photo: \(photo.id)")
        } catch {
            throw PSError.deletePhoto(underlyingError: error)
        }
    }
    
    func getPhotoCount() async throws -> Int {
        let userKey = PersistenceManager.retrieveKey()
        do {
            let photos = try await dbHelper.fetchPhotos(for: userKey)
            return photos.count
        } catch {
            throw PSError.photoCount(underlyingError: error)
        }
    }   
    
    func getNewKey() async throws -> Int {
        do {
            let result = try await functions.httpsCallable("generateUniqueKey").call()
            if let data = result.data as? [String: Any], let newKey = data["newKey"] as? Int {
             return newKey
            } else {
                return 0
            }
        } catch {
            print("Error fethcing unqiue key from serveR: \(error)")
            Crashlytics.crashlytics().log("Error during getNewKey in network manager with error: \(error)")
            Crashlytics.crashlytics().record(error: error)
            throw error
            
        }        
    }
    
    func initializeKey(pairingKey: Int) async throws {
        do {
            let result = try await functions.httpsCallable("initializeKey").call(["pairingKey": pairingKey])
            if let data = result.data as? [String: Any], let message = data["message"] as? String {
                print(message)
            }
        } catch {
            Crashlytics.crashlytics().log("Error during initializeKey in networkmanager with error: \(error)")
            Crashlytics.crashlytics().record(error: error)
            throw PSError.initializeKey(underlyingError: error)
        }
        
       }
    
    func setClaims(with userKey: Int) async throws {
        
        let user = try await PersistenceManager.getAuthUser()
        let uid = user.uid
        
        do {
            let result = try await functions.httpsCallable("setCustomClaims").call(["uid": uid, "pairingKey": userKey])
            print(result.data)
          
        } catch {
            Crashlytics.crashlytics().log("Error during setClaims in network manager with error: \(error)")
            Crashlytics.crashlytics().record(error: error)
            throw PSError.setClaims(underlyingError: error)
        }
    }
    
    func setClaimsToCurrentKey() async throws {
        let userKey = PersistenceManager.retrieveKey()
        
        let user = try await PersistenceManager.getAuthUser()
        let uid = user.uid
        
        if userKey == 0 {
            print("Key was 0 when it shouldve been set. Not subscribing to claim")
            throw PSError.invalidKey()
        }
        
        do {
            let result = try await functions.httpsCallable("setCustomClaims").call(["uid": uid, "pairingKey": userKey])
            print(result.data)
            try await user.idTokenForcingRefresh(true)        
          
        } catch {
            throw PSError.setClaims(underlyingError: error)
        }
    }
    
    func fetchDog() async throws -> Dog {
        let key = PersistenceManager.retrieveKey()
        print("attempting fetch dog for key \(key)")
        return try await dbHelper.fetchDogInfo(for: key)
    }
    
    func fetchDogForKey(_ key: Int) async throws -> Dog {
        return try await dbHelper.fetchDogInfo(for: key)
    }
    
    func setDog(to dog: Dog) async throws {
        try await dbHelper.addDogInfo(dog: dog)
    }
    
    func changeDogName(to name: String) {
        dbHelper.updateDogName(to: name)
    }
    
    func changeDogPhoto(to photo: String) {
        dbHelper.updateDogPhoto(to: photo)
    }
   
    func checkIfKeyExists(key: String) async throws -> Bool {
        let functions = Functions.functions()
        
        let result = try await functions.httpsCallable("checkIfKeyExists").call(["key": key])
        
        if let data = result.data as? [String: Any], let exists = data["exists"] as? Bool {
            return exists
        } else {
            throw NSError(domain: "InvalidResponse", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"])
        }
    }

}

