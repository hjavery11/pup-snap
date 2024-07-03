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
    let firebaseHelper = FirebaseHelper()
    
    
    
    private init() {}
    
    
    func getPhotos() async -> [UIImage] {
        let imageArray = try! await firebaseHelper.fetchAllImages()
        return imageArray
    }
    
    func uploadPhoto(image: UIImage, progressHandler: @escaping (Double) -> Void, successHandler: @escaping () -> Void, failureHandler: @escaping (Error) -> Void) -> StorageUploadTask? {
        return firebaseHelper.uploadImage(image: image, progressHandler: progressHandler, successHandler: successHandler, failureHandler: failureHandler)
    }
    
    
    
}
