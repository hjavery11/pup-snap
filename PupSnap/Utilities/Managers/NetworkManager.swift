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
        Task {
            try await DatabaseHelper().addPhotoToDB(photo: photo)
        }
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
    
    func retrieveAllKeys() async throws -> [Int] {
        do {
            let result = try await functions.httpsCallable("getAllKeys").call()
            if let data = result.data as? [String: Any],
               let keys = data["keys"] as? [Int] {
                return keys
            } else {
                return []
            }
        } catch {
            throw PSError.retrieveAllKeys(underlyingError: error)
        }
        
    }
    
    func initializeKey(pairingKey: Int) async throws {
        do {
            let result = try await functions.httpsCallable("initializeKey").call(["pairingKey": pairingKey])
            if let data = result.data as? [String: Any], let message = data["message"] as? String {
                print(message)
            }
        } catch {
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
   

}

