//
//  DatabaseHelper.swift
//  SophiePhotos
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
        
        guard let path = photo.imagePath else {
            print("no image path set, cancelling upload to DB")
            return
        }
        
        let valueArray = ["caption": photo.caption,
                          "ratings": [photo.ratings[0].user : photo.ratings[0].rating],
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
    
    func fetchAllPhotosFromDB() async throws -> [Photo] {
        do {
            let snapshot = try await ref.child("photos").getData()
            guard let value = snapshot.value as? [String: [String: Any]] else {
                throw NSError(domain: "Invalid data format", code: -1, userInfo: nil)
            }
            
            var photos: [Photo] = []
            
            for (key, photoData) in value {
                guard let caption = photoData["caption"] as? String,
                      let ratingsArray = photoData["ratings"] as? [String: Int],
                      let path = photoData["path"] as? String,
                      let timestamp = photoData["timestamp"] as? Int else {
                    print("Invalid data for photo ID \(key)")
                    continue
                }
                
                var ratings: [Photo.Rating] = []
                
                for(user, rating) in ratingsArray {
                    let ratingObj = Photo.Rating(user: user, rating: rating)
                    ratings.append(ratingObj)
                }
                
                var photoImage = UIImage()
                
                if let image = loadImageFromDisk(with: path) { // first check to see if we have the image cached before getting from storage
                    photoImage = image
                } else {
                    do {
                        photoImage = try await FirebaseHelper().fetchImage(url: path)
                    } catch {
                        print("Error retrieving image from storage for: \(path)")
                        throw error
                    }
                }
                
                let photo = Photo(caption: caption, ratings: ratings, id: key, image: photoImage, imagePath: path, timestamp: timestamp)
                
                photos.append(photo)
            }
            
            return photos
        } catch {
            print("Error fetching photos: \(error.localizedDescription)")
            throw error
        }
    }
    
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
//            "ratings": [PersistenceManager.retrieveID() : 3],
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
