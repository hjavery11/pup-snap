//
//  DatabaseHelper.swift
//  SophiePhotos
//
//  Created by Harrison Javery on 7/5/24.
//

import Foundation
import FirebaseDatabaseInternal

class DatabaseHelper {
    
    var ref: DatabaseReference!
    
    init() {
        ref = Database.database().reference()
    }
    
    func addPhotoToDB(photo: Photo) {
        
        guard let path = photo.imagePath else {
            print("no image path set, cancelling upload to DB")
            return
        }
        
        let valueArray = ["caption": photo.caption,
                          "ratings": ["user": photo.ratings[0].user, "rating": photo.ratings[0].rating],
                          "path": path,
                          "timestamp": Int(Date().timeIntervalSince1970)] as [String : Any]
        
        let uniqueID = photo.id
        
        self.ref.child("photos").child(uniqueID).updateChildValues(valueArray) { error, _ in
            if let error = error {
                print("Error setting value: \(error.localizedDescription)")
                print("ValueArray: \(valueArray)")
            } else {
                print("Photo uploaded succesfully")
            }
            
        }        
    }
    
}

// All this is DB setup script for syncing out of sync firebase storage with realtime database
//import Firebase
//import FirebaseDatabase
//import FirebaseStorage
//import FirebaseCore
//import UIKit
//
//class PhotoDatabaseManager {
//
//    static let shared = PhotoDatabaseManager()
//    
//    private init() {
//    }
//    
//    private let databaseRef = Database.database().reference()
//    private let storageRef = Storage.storage().reference().child("images")
//    private let cache = NSCache<NSString, UIImage>()
//
//    // Function to generate a unique ID
//    private func generateUniqueID() -> String {
//        return UUID().uuidString
//    }
//
//    // Function to create photo data
//    private func createPhotoData(id: String, path: String) -> [String: Any] {
//        let photoData: [String: Any] = [
//            "caption": "",
//            "ratings": ["user" : PersistenceManager.retrieveID(), "rating" : 3],
//            "path": path,
//            "timestamp": Int(Date().timeIntervalSince1970)
//        ]
//        return [id: photoData]
//    }
//
//    // Function to save photos metadata to Firebase Realtime Database
//    private func savePhotoMetadataToDatabase(photoData: [String: Any]) {
//        databaseRef.child("photos").updateChildValues(photoData) { error, ref in
//            if let error = error {
//                print("Error saving photos to database: \(error.localizedDescription)")
//            } else {
//                print("Successfully saved photos to database")
//            }
//        }
//    }
//    
//    // Function to fetch all images and their URLs
//    func fetchAllImages() async throws -> Void {
//       print("Attemtping image fix")
//        var photosData: [String: Any] = [:]
//        
//        do {
//            let result = try await storageRef.listAll()
//            for item in result.items {
//
//                // Create photo data and add to the dictionary
//                let uniqueID = generateUniqueID()
//                let photoData = createPhotoData(id: uniqueID, path: item.fullPath)
//                photosData.merge(photoData) { (current, _) in current }
//            }
//            
//            // Save photo metadata to the database
//            savePhotoMetadataToDatabase(photoData: photosData)
//            //print(photosData)
//        } catch {
//            print("Error listing items: \(error)")
//        }
//        
//       
//    }
//}
