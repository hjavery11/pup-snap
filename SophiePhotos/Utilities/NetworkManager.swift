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

    private init() {}

    func getPhotos() async -> ([UIImage], [String]) {
        do {
            let (imageArray, urlArray) = try await firebaseHelper.fetchAllImages()
            return (imageArray, urlArray)
        } catch {
            print("error on getting photos: \(error)")
            return ([], [])
        }
    }

    func uploadPhoto(photo: Photo, progressHandler: @escaping (Double) -> Void, successHandler: @escaping () -> Void, failureHandler: @escaping (Error) -> Void) -> StorageUploadTask? {
        return firebaseHelper.uploadImage(photo: photo, progressHandler: progressHandler, successHandler: successHandler, failureHandler: failureHandler)
    }

    func getPhoto(_ url: String, completion: @escaping (UIImage?) -> Void) {
        firebaseHelper.fetchImage(url: url) { image in
            completion(image)
        }
    }

    func deletePhoto(imageURL: String) async throws {
       try await firebaseHelper.deleteImage(url: imageURL)
    }

}
