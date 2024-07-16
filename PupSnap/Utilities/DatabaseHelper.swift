//
//  DatabaseHelper.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/5/24.
//

import Foundation
import FirebaseDatabaseInternal
import UIKit

class DatabaseHelper {

    var ref: DatabaseReference!

    
    init() {
        ref = Database.database().reference()
    }
    
    func addPhotoToDB(photo: Photo) {
        let userKey = PersistenceManager.retrieveKey()
        let photosRef = ref.child(String(userKey)).child("photos")
        guard let path = photo.path else {
            print("No path was found to add to db for photo: \(photo.id ?? "")")
            return
        }
        guard let uniqueID = photo.id else {
            print("No unique id found for photo with path \(path)")
            return
        }
        
        let valueArray = ["caption": photo.caption,
                          "ratings": photo.ratings,
                          "path": path,
                          "timestamp": Int(Date().timeIntervalSince1970)] as [String : Any]
        
        photosRef.child(uniqueID).updateChildValues(valueArray) { error, _ in
            if let error = error {
                print("Error setting value: \(error.localizedDescription)")
                print("ValueArray: \(valueArray)")
            } else {
                print("Photo uploaded succesfully to database")
            }
            
        }
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
        guard let photoId = photo.id else {
            print("No unique photo found for photo")
            throw SophieError.photoAccess
        }
        
        let ratingRef = photosRef.child(photoId).child("ratings")
        
        try await ratingRef.updateChildValues(photo.ratings)
        

        
    }
    
    func deletePhotoFromDB(photo: Photo) async throws{
        let userKey = PersistenceManager.retrieveKey()
        let photosRef = ref.child(String(userKey)).child("photos")
        if let id = photo.id{
            try await photosRef.child(id).removeValue()
        } else {
            print("no id found for photo to delete: \(photo)")
        }
    }
    
    func fetchPhotos() async throws -> [Photo]{
        let userKey = PersistenceManager.retrieveKey()
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
            for(key, _) in photoDictionary {
                photoDictionary[key]?.id = key
            }
            
            let photos = Array<Photo>(photoDictionary.values)
            return photos
        } catch {
            print("error in DatabaseHelper fetchPhotos()")
            throw error
        }
    }
    
    func retrieveAllKeys() async throws -> [Int]{
        let snapshot = try await ref.getData()
        guard let topLevelData = snapshot.value as? [String: Any] else {
            print("No top-level data found")
            return []
        }
        
        let allKeys = topLevelData.keys.compactMap { key -> Int? in
            let intKey = Int(key)
            return intKey
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
//
//class PhotoDatabaseManager {
//
//    static let shared = PhotoDatabaseManager()
//
//    private init() {
//    }
//
//    private let databaseRef = Database.database().reference()
//
//    // Function to generate a random 8-digit integer
//    private func generateRandom8DigitInteger() -> Int {
//        return Int.random(in: 10000000...99999999)
//    }
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
