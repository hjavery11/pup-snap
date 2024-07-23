//
//  DatabaseHelper.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/5/24.
//

import Foundation
import FirebaseDatabase
import UIKit

class DatabaseHelper {
    
    var ref: DatabaseReference!
    
    
    init() {
        ref = Database.database().reference()
    }
    func fetchPhotos(for userKey: Int) async throws -> [Photo]{
        let photosRef = ref.child(String(userKey)).child("photos")
        do{
            let snapshot = try await photosRef.getData()
            
            guard let value = snapshot.value as? [String: Any] else {
                return []
            }
            
            let jsonData = try JSONSerialization.data(withJSONObject: value)
            let decoder = JSONDecoder()
            let photoDictionary = try decoder.decode(PhotoDictionary.self, from: jsonData)
            
            // Set the `id` for each `Photo` to the corresponding key
            var photos: [Photo] = []
            for (key, photo) in photoDictionary {
                let photo = photo
                photo.id = key
                photos.append(photo)
            }
            
            return photos
        } catch let error as NSError {
            if error.domain == "com.firebase.core" && error.code == 1 {
                print("Permission denied error. Attempting to resub to claims")
                // Handle the permission denied error by calling setClaims
                do {
                    try await NetworkManager.shared.setClaimsToCurrentKey()
                 
                    let snapshot = try await photosRef.getData()
                    
                    guard let value = snapshot.value as? [String: Any] else {
                        return []
                    }
                    
                    let jsonData = try JSONSerialization.data(withJSONObject: value)
                    let decoder = JSONDecoder()
                    let photoDictionary = try decoder.decode(PhotoDictionary.self, from: jsonData)
                    
                    var photos: [Photo] = []
                    for (key, photo) in photoDictionary {
                        let mutablePhoto = photo
                        mutablePhoto.id = key
                        photos.append(mutablePhoto)
                    }
                    
                    return photos
                } catch {
                    // Handle errors from setClaims or retrying fetching photos
                    throw PSError.fetchPhotos(underlyingError: error)
                }
            } else {
                print("Other error: \(error.localizedDescription)")
                throw PSError.fetchPhotos(underlyingError: error)
            }
        }
    }
    
    func addDogInfo(dog: Dog) async throws {
        let dogRef = ref.child(String(PersistenceManager.retrieveKey())).child("dog")
        
        let valueArray = ["name": dog.name,
                          "photo": dog.photo ] 
        
        try await dogRef.updateChildValues(valueArray)
    }
    
    func fetchDogInfo(for key: Int) async throws -> Dog {
        let dogRef = ref.child(String(key)).child("dog")
        
        let snapshot = try await dogRef.getData()
        
        guard let value = snapshot.value as? [String: String] else {
            print("No dog found, returning sophie")
            let baseDog = Dog(photo: "sophie-iso", name: "Sophie")
            try await addDogInfo(dog: baseDog)
            return baseDog
        }
        
        let jsonData = try JSONSerialization.data(withJSONObject: value)
        let decoder = JSONDecoder()
        let dogData = try decoder.decode(Dog.self, from: jsonData)
        
        return Dog(photo: dogData.photo, name: dogData.name)

    }
    
    func updateDogName(to name: String) {
        let dogRef = ref.child(String(PersistenceManager.retrieveKey())).child("dog").child("name")
        
        dogRef.setValue(name)
    }
    
    func updateDogPhoto(to photo: String) {
        let dogRef = ref.child(String(PersistenceManager.retrieveKey())).child("dog").child("photo")
        
        dogRef.setValue(photo)
    }
    
    func addPhotoToDB(photo: Photo) async throws {
        let userKey = PersistenceManager.retrieveKey()
        let photosRef = ref.child(String(userKey)).child("photos")
        
        let valueArray = ["caption": photo.caption,
                          "ratings": photo.ratings,
                          "timestamp": Int(Date().timeIntervalSince1970)] as [String : Any]
        
        try await photosRef.child(photo.id).updateChildValues(valueArray)
        
    }
    
    func checkPhotoLimit() async throws-> Bool {
        let maxPhotosString = RemoteConfigManager.shared.getValue(forKey: RemoteConfigManager.Keys.maxPhotos)
        guard let maxPhotosPerUser = Int(maxPhotosString) else {
            print("Invalid max photos per user value")
            throw NSError(domain: "DatabaseHelper", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid max photos per user value"])
        }
        
        //retireve photo count for user
        let userKey = PersistenceManager.retrieveKey()
        let photosRef = ref.child(String(userKey)).child("photos")
        
        do {
            let snapshot = try await photosRef.getData()
            let photoCount = snapshot.childrenCount
            print("Allowing upload with photoCount of: \(photoCount) and max allowed of: \(maxPhotosPerUser)")
            
            if photoCount > maxPhotosPerUser {
                throw NSError(domain: "DatabaseHelper", code: 2, userInfo: [NSLocalizedDescriptionKey: "You have reached the maximum number of photos allowed: \(maxPhotosPerUser)."])
            }
            
            return true
            
        } catch {
            throw NSError(domain: "DatabaseHelper", code: 3, userInfo: [NSLocalizedDescriptionKey: "\(error.localizedDescription)"])
        }
        
        
    }
    
    func editPhotoRating(photo:Photo) async throws{
        let userKey = PersistenceManager.retrieveKey()
        let photosRef = ref.child(String(userKey)).child("photos")
        let photoId = photo.id
        
        let ratingRef = photosRef.child(photoId).child("ratings")
        
        try await ratingRef.updateChildValues(photo.ratings)
        
        
        
    }
    
    func deletePhotoFromDB(photo: Photo, last: Bool) async throws{
        let userKey = PersistenceManager.retrieveKey()
        let photosRef = ref.child(String(userKey)).child("photos")
        
        
        if last {
            try await ref.child(String(userKey)).setValue("")
        } else {
            try await photosRef.child(photo.id).removeValue()
        }
        
        
        
    }
    
    func retrieveAllKeys() async throws -> [Int]{
        let snapshot = try await ref.child("publicKeys").getData()
        guard let topLevelData = snapshot.value as? [String: Bool] else {
            print("No top-level data found")
            return []
        }
        
        let allKeys = topLevelData.keys.compactMap { key -> Int? in
            return Int(key)
        }
        
        return allKeys
    }
}

extension DatabaseHelper {
    
    // Function to get local file URL
    private func getLocalFileURL(fileName: String) -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory.appendingPathComponent(fileName)
    }
    
    // Function to load image from disk
    private func loadImageFromDisk(with fileName: String) -> UIImage? {
        let fileURL = getLocalFileURL(fileName: fileName)
        if let data = try? Data(contentsOf: fileURL) {
            return UIImage(data: data)
        }
        return nil
    }
}



// All this is DB setup script for syncing out of sync firebase storage with realtime database
//import Foundation
//import FirebaseDatabase
//import FirebaseStorage
//import FirebaseAuth
//
//class PhotoDatabaseManager {
//    
//    static let shared = PhotoDatabaseManager()
//    private let storageRef = Storage.storage().reference().child("images")
//    private let databaseRef = Database.database().reference().child("56706732/photos")
//    
//    private init() {
//    }
//    
//    func syncPhotosToDatabase() {
//        // List all files under images/
//        storageRef.listAll { (result, error) in
//            if let error = error {
//                print("Error listing files: \(error.localizedDescription)")
//                return
//            }
//            
//            // Iterate through the items
//            for item in result!.items {
//                let path = item.fullPath
//                self.createDatabaseEntry(for: path)
//            }
//        }
//    }
//    
//    private func createDatabaseEntry(for path: String) {
//        let photoID = UUID().uuidString
//        let photoRef = databaseRef.child(photoID)
//        
//        // Create a photo object with default values
//        let photoObject: [String: Any] = [
//            "caption": "", // default caption
//            "ratings": [PersistenceManager.retrieveID() : 0], // default empty ratings dictionary
//            "path": path,
//            "timestamp": Int(Date().timeIntervalSince1970)
//        ]
//        
//        // Write to the database
//        photoRef.setValue(photoObject) { (error, ref) in
//            if let error = error {
//                print("Error creating database entry: \(error.localizedDescription)")
//            } else {
//                print("Database entry created for path: \(path)")
//            }
//        }
//    }
//    
//    // Function to generate a random 8-digit integer
//    private func generateRandom8DigitInteger() -> Int {
//        return Int.random(in: 10000000...99999999)
//    }
//    
//    
//    
//    
//    // Function to move photo data to a new top-level key
//    func movePhotosToNewKey() {
//        // Step 1: Retrieve everything currently under "photos"
//        databaseRef.child("photos").observeSingleEvent(of: .value) { snapshot in
//            guard let photosData = snapshot.value as? [String: Any] else {
//                print("No photos data found")
//                return
//            }
//            
//            // Step 2: Create a new top-level key and set it to a random 8-digit integer
//            let randomKey = self.generateRandom8DigitInteger()
//            let keyString = String(randomKey)
//            
//            // Step 3: Move everything from "photos" to inside that 8-digit key
//            self.databaseRef.child(keyString).child("photos").setValue(photosData) { error, _ in
//                if let error = error {
//                    print("Error moving photos to new key: \(error.localizedDescription)")
//                    return
//                } else {
//                    print("Successfully moved photos to new key")
//                    
//                    // Delete old "photos" node after moving
//                    self.databaseRef.child("photos").removeValue { error, _ in
//                        if let error = error {
//                            print("Error deleting old photos node: \(error.localizedDescription)")
//                        } else {
//                            print("Successfully deleted old photos node")
//                        }
//                    }
//                }
//            }
//        }
//    }
//}
