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
        ref = Database.database().reference().child("photos")
    }
    
    func addPhotoToDB(photo: Photo) {        
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
        
        self.ref.child(uniqueID).updateChildValues(valueArray) { error, _ in
            if let error = error {
                print("Error setting value: \(error.localizedDescription)")
                print("ValueArray: \(valueArray)")
            } else {
                print("Photo uploaded succesfully to database")
            }
            
        }
    }
    
    func editPhotoRating(photo:Photo) async throws{
        guard let photoId = photo.id else {
            print("No unique photo found for photo")
            throw SophieError.photoAccess
        }
        
        let ratingRef = ref.child(photoId).child("ratings")
        
        try await ratingRef.updateChildValues(photo.ratings)
        

        
    }
    
    func deletePhotoFromDB(photo: Photo) async throws{
        if let id = photo.id{
            try await ref.child(id).removeValue()
        } else {
            print("no id found for photo to delete: \(photo)")
        }
    }
    
    func fetchPhotos() async throws -> [Photo]{
        do{
            let snapshot = try await ref.getData()
            
            guard let value = snapshot.value as? [String: Any] else {
                throw NSError(domain: "", code: -1)
            }
            
            let jsonData = try JSONSerialization.data(withJSONObject: value)
            let decoder = JSONDecoder()
            var photoDictionary = try decoder.decode(PhotoDictionary.self, from: jsonData)
            
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
