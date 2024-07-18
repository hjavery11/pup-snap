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
    private let firebaseHelper = FirebaseHelper()
    private let dbHelper = DatabaseHelper()
    private let functions = Functions.functions()

    private init() {}

    func fetchCompletePhotos() async throws -> [Photo] {
        var photos: [Photo] = []
        
        do {
            photos = try await dbHelper.fetchPhotos()
            print("done with database fetch")
            
            try await withThrowingTaskGroup(of: (Int, UIImage?).self) { group in
                for (index, photo) in photos.enumerated() {
                    group.addTask {
                        guard let image = try? await self.firebaseHelper.fetchImage(url: photo.path ?? "") else {
                            return (index, nil)
                        }
                        return (index, image)
                    }
                }
                
                var photosWithImages: [Photo] = []
                
                for try await (index, image) in group {
                    if let image = image {
                        let photo = photos[index]
                        photo.image = image
                        photosWithImages.append(photo)
                    }
                }
                
                photos = photosWithImages
                
            }
        } catch {
            throw PSError.fetchPhotos(underlyingError: error)
        }
        
        let sortedPhotos = photos.sorted()
        return sortedPhotos

    }

    func uploadPhoto(photo: Photo, progressHandler: @escaping (Double) -> Void, successHandler: @escaping () -> Void, failureHandler: @escaping (Error) -> Void) -> StorageUploadTask? {
        return firebaseHelper.uploadImage(photo: photo, progressHandler: progressHandler, successHandler: successHandler, failureHandler: failureHandler)
    }
    
    func checkPhotoLimit() async throws -> Bool {
        return try await dbHelper.checkPhotoLimit()
    }
    
    func updatePhotoRating(photo: Photo) async throws {
        try await dbHelper.editPhotoRating(photo: photo)
    }
  

    func deletePhoto(photo: Photo, last: Bool) async throws {
        do {
            try await firebaseHelper.deleteImage(url: photo.path!)
            try await dbHelper.deletePhotoFromDB(photo: photo, last: last)
            print("deleted photo: \(photo.path ?? "") and id: \(String(describing: photo.id))")
        } catch {
            throw PSError.deletePhoto(underlyingError: error)
        }
    }
    
    func getPhotoCount() async throws -> Int {
        do {
            let photos = try await dbHelper.fetchPhotos()
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
    
    func setClaims(for user: User, with userKey: Int) async throws {
        do {
            let result = try await functions.httpsCallable("setCustomClaims").call(["uid": user.uid, "pairingKey": userKey])
            print(result.data)
        } catch {
            throw PSError.setClaims(underlyingError: error)
        }
    }
   

}

