//
//  FirebaseHelper.swift
//  SophiePhotos
//
//  Created by Harrison Javery on 7/2/24.
//

import Foundation
import FirebaseStorage
import UIKit

class FirebaseHelper {
    // Get a reference to the storage service using the default Firebase App/
    let storage: Storage
    
    // Create a storage reference from our storage service
    let storageRef: StorageReference
    
    private let cache = NSCache<NSString, UIImage>()
    
    
    init() {
        // Get a reference to the storage service using the default Firebase App/
        storage = Storage.storage()
        
        // Create a storage reference from our storage service
        storageRef = storage.reference().child("images")
        
    }
    
    func fetchAllImages() async throws -> [UIImage] {
        
        var images: [UIImage] = []
        do {
            let result = try await storageRef.listAll()
            for item in result.items {
                let cacheKey = NSString(string: item.fullPath)
                
                //check in memory cache see if we have the image in cache first
                if let cachedImage = cache.object(forKey: cacheKey) {
                    images.append(cachedImage)
                    continue
                }
                
                if let fileImage = loadImageFromDisk(with: item.fullPath) {
                    cache.setObject(fileImage, forKey: cacheKey) //update in-memory cache
                    images.append(fileImage)
                    continue
                }
                
                //otherwise download the image data and save to local file system
                do {
                    let localURL = getLocalFileURL(fileName: item.fullPath)
                    try await downloadImageToLocalFile(from: item, to: localURL)
                    if let image = loadImageFromDisk(with: item.fullPath) {
                        //cache the image
                        cache.setObject(image, forKey: cacheKey)
                        images.append(image)
                    }
                } catch {
                    print("Error downloading image data: \(error)")
                }
            }
        } catch {
            print("Error listing items: \(error)")
        }
        return images
    }
    
    func fetchImage(url: String, completion: @escaping (UIImage?) -> Void) {
        let photoRef = storage.reference().child(url)
        //start download
        photoRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
            if let error = error {
                print("Issue loading image: \(url) with error: \(error.localizedDescription)")
                completion(nil)
            } else if let data = data, let image = UIImage(data:data){
               completion(image)
            } else {
                completion(nil)
            }
        }
    }
    
    func uploadImage(image: UIImage, progressHandler: @escaping (Double) -> Void, successHandler: @escaping () -> Void, failureHandler: @escaping (Error) -> Void) -> StorageUploadTask? {
        guard let imageData = image.pngData() else {
            print("Failed to get image data")
            return nil
        }
        
        //create a reference to the file
        let imageRef = storageRef.child((UUID().uuidString) + ".png")
        
        //upload the file to the path images/[UUID].png
        let uploadTask = imageRef.putData(imageData, metadata: nil) { metadata, error in
            guard let _ = metadata else {
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
                successHandler()
            }
            
        }
      
        
        //monitor upload progress
        uploadTask.observe(.progress) { snapshot in
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            print("Upload progress: \(percentComplete)")
            progressHandler(percentComplete)
        }
        
        //handle upload failure
        
        uploadTask.observe(.failure) { snapshot in
            if let error = snapshot.error {
                failureHandler(error)
            }
        }
        
        return uploadTask
        
    }
    
    
    
    
    
    
    
    
    
    
    private func downloadImageToLocalFile(from reference: StorageReference, to localURL: URL) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            reference.write(toFile: localURL) {url, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }
    
    private func saveImageToDisk(image: UIImage, fileName: String) {
        if let data = image.pngData() {
            let fileURL = getLocalFileURL(fileName: fileName)
            try? data.write(to: fileURL)
        }
    }
    
    //load image from disk
    private func loadImageFromDisk(with fileName: String) -> UIImage? {
        let fileURL = getLocalFileURL(fileName: fileName)
        if let data = try? Data(contentsOf: fileURL) {
            return UIImage(data: data)
        }
        //return nothing if no image
        return nil
    }
    
    
    //get the local file URL
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
    
    //get the documents directory
    private func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    
}





extension StorageReference {
    func getData(maxSize: Int64) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            self.getData(maxSize: maxSize) { data, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let data = data {
                    continuation.resume(returning: data)
                } else {
                    continuation.resume(throwing: NSError(domain: "FirebaseHelper", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred"]))
                }
            }
        }
    }
}
