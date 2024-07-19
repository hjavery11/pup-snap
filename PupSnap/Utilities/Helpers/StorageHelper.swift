//
//  FirebaseHelper.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/2/24.
//

import Foundation
import FirebaseStorage
import UIKit

class StorageHelper {
    // Get a reference to the storage service using the default Firebase App/
    let storage: Storage
    // Create a storage reference from our storage service
    let storageRef: StorageReference
    let baseStorageRef: StorageReference
    private let cache = NSCache<NSString, UIImage>()
    init() {
        // Get a reference to the storage service using the default Firebase App/
        storage = Storage.storage()
        // Create a storage reference from our storage service
        storageRef = storage.reference().child("images")
        
        baseStorageRef = storage.reference()
        
    }
    
    func fetchImage(url: String) async throws -> UIImage? {
        let photoRef = Storage.storage().reference().child(url)
        let cacheKey = NSString(string: url)
        
        if let cachedImage = cache.object(forKey: cacheKey) { // check in memory first so we have it in cache
            print("did return cached image")
            return cachedImage
        }
        
        //see if its on disk
        let fileName = url.replacingOccurrences(of: "/", with: "_")
        if let diskImage = loadImageFromDisk(with: fileName) {
            print("Returned image from disk")
            cache.setObject(diskImage, forKey: cacheKey)
            return diskImage
        }
        
        //otherwise download image and save to cache
        do {
            let data = try await photoRef.data(maxSize: 5 * 1024 * 1024)
            guard let image = UIImage(data: data) else {
                print("error making image from data")
                return nil
            }
            
            
            saveImageToDisk(image: image, fileName: fileName)
            cache.setObject(image, forKey: cacheKey)
            return image
            
        } catch {
            print(error)
            return nil
        }
    }
    
    func fetchAllImages(for key: Int) async throws {
        //let photoRef = storageRef.child(String(key))
        //let data = try await photoRef.data
        
    }
    
    
    
    func uploadImage(photo: Photo, progressHandler: @escaping (Double) -> Void, successHandler: @escaping () -> Void, failureHandler: @escaping (Error) -> Void) -> StorageUploadTask? {
        let userKey = PersistenceManager.retrieveKey()
        guard let imageData = photo.image?.jpegData(compressionQuality: 0.7) else {
            print("Failed to get image data")
            return nil
        }
        
        // create a reference to the file
        let imageRef = storageRef.child(String(userKey)).child(photo.id + ".jpg")
        
        // Create metadata for the upload
           let metadata = StorageMetadata()
           metadata.contentType = "image/jpeg"
        
        // upload the file to the path
        let uploadTask = imageRef.putData(imageData, metadata: metadata) { metadata, error in
            guard metadata != nil else {
                print("Upload error: \(String(describing: error?.localizedDescription))")
                failureHandler(error!)
                return
            }
            
            imageRef.downloadURL { url, error in
                guard let downloadURL = url else {
                    print("Download URL error: \(String(describing: error?.localizedDescription))")
                    failureHandler(error!)
                    return
                }
                
                print("Download URL: \(downloadURL.absoluteString)")
                
                DispatchQueue.main.async {
                    successHandler()
                    
                }
            }
            
        }
        
        // monitor upload progress
        uploadTask.observe(.progress) { snapshot in
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            print("Upload progress: \(percentComplete)")
            progressHandler(percentComplete)
        }
        
        // handle upload failure
        
        uploadTask.observe(.failure) { snapshot in
            if let error = snapshot.error {
                failureHandler(error)
            }
        }
        
        return uploadTask
        
    }
    
    func deleteImage(id: String) async throws {
        let userKey = PersistenceManager.retrieveKey()
        
        let deleteRef = storageRef.child(String(userKey)).child(id + ".jpg")
        try await deleteRef.delete()
    }
    
    private func downloadImageToLocalFile(from reference: StorageReference, to localURL: URL) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            reference.write(toFile: localURL) { _, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }
    
    private func saveImageToDisk(image: UIImage, fileName: String) {
        if let data = image.jpegData(compressionQuality: 0.8) {
            let fileURL = getLocalFileURL(fileName: fileName)
            try? data.write(to: fileURL)
        }
    }
    
    // load image from disk
    private func loadImageFromDisk(with fileName: String) -> UIImage? {
        let fileURL = getLocalFileURL(fileName: fileName)
        if let data = try? Data(contentsOf: fileURL) {
            return UIImage(data: data)
        }
        // return nothing if no image
        return nil
    }
    
    // get the local file URL
    private func getLocalFileURL(fileName: String) -> URL {
        let documentsDirectory = getDocumentsDirectory()
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        let fileDirectory = fileURL.deletingLastPathComponent()
        
        // create directory if it doesnt exist
        if !FileManager.default.fileExists(atPath: fileDirectory.path) {
            try? FileManager.default.createDirectory(at: fileDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        
        return fileURL
    }
    
    // get the documents directory
    private func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
}


