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

    func getPhotos() async -> [Photo] {
        do {
            let photos = try await dbHelper.fetchAllPhotosFromDB()
            return photos
        } catch {
            print("error on getting photos: \(error)")
            return []
        }
    }

    func uploadPhoto(photo: Photo, progressHandler: @escaping (Double) -> Void, successHandler: @escaping () -> Void, failureHandler: @escaping (Error) -> Void) -> StorageUploadTask? {
        return firebaseHelper.uploadImage(photo: photo, progressHandler: progressHandler, successHandler: successHandler, failureHandler: failureHandler)
    }

    func getPhoto(_ url: String) async -> UIImage? {
        do {
            return try await firebaseHelper.fetchImage(url: url)
        } catch {
            print("error getting photo at url: \(url)")
            return nil
        }
    }

    func deletePhoto(imageURL: String) async throws {
       try await firebaseHelper.deleteImage(url: imageURL)
    }

}
