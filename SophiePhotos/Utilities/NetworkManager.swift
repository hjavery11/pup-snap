//
//  NetworkManager.swift
//  SophiePhotos
//
//  Created by Harrison Javery on 7/2/24.
//

import UIKit
import FirebaseStorage

class NetworkManager {
    static let shared = NetworkManager()
    private let firebaseHelper = FirebaseHelper()
    private let dbHelper = DatabaseHelper()

    private init() {}

    func fetchCompletePhotos() async throws -> [Photo] {
        var photos: [Photo] = []
        
        do {
            photos = try await dbHelper.fetchPhotos()
            print("done with database fetch")
            
            try await withThrowingTaskGroup(of: (Int, UIImage?).self) { group in
                for (index, photo) in photos.enumerated() {
                    group.addTask {
                        guard let image = try? await self.firebaseHelper.fetchImage(url: photo.path) else {
                            return (index, nil)
                        }
                        return (index, image)
                    }
                }
                
                var photosWithImages: [Photo] = []
                
                for try await (index, image) in group {
                    if let image = image {
                        var photo = photos[index]
                        photo.image = image
                        photosWithImages.append(photo)
                    }
                }
                
                photos = photosWithImages
                
            }
        } catch {
            print("Error in fetching compelte photos: \(error)")
            throw error
        }
        
        return photos

    }

//    func uploadPhoto(photo: Photo, progressHandler: @escaping (Double) -> Void, successHandler: @escaping () -> Void, failureHandler: @escaping (Error) -> Void) -> StorageUploadTask? {
//        return firebaseHelper.uploadImage(photo: photo, progressHandler: progressHandler, successHandler: successHandler, failureHandler: failureHandler)
//    }
//  

    func deletePhoto(imageURL: String) async throws {
       try await firebaseHelper.deleteImage(url: imageURL)
    }

}

