//
//  SophieError.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/5/24.
//

import Foundation

enum PSError: Error {
    case localdata(underlyingError: Error? = nil)
    case photoAccess(underlyingError: Error? = nil)
    case invalidKey(underlyingError: Error? = nil)
    case retrieveAllKeys(underlyingError: Error? = nil)
    case initializeKey(underlyingError: Error? = nil)
    case setClaims(underlyingError: Error? = nil)
    case photoCount(underlyingError: Error? = nil)
    case deletePhoto(underlyingError: Error? = nil)
    case fetchPhotos(underlyingError: Error? = nil)
    case subscribeError(underlyingError: Error? = nil)
    case authError(underlyingError: Error? = nil)
    case unsubscribeError(underlyingError: Error? = nil)
    
    var localizedDescription: String {
        switch self {
        case .localdata(let underlyingError):
            return "Error accessing local data. \(underlyingError?.localizedDescription ?? "")"
        case .photoAccess(let underlyingError):
            return "We couldn't find a photo in the database. Please try again. \(underlyingError?.localizedDescription ?? "")"
        case .invalidKey(let underlyingError):
            return "The pairing key you entered does not exist. Please double check your info. \(underlyingError?.localizedDescription ?? "")"
        case .retrieveAllKeys(let underlyingError):
            return "There was an issue retrieving all keys. \(underlyingError?.localizedDescription ?? "")"
        case .initializeKey(let underlyingError):
            return "Something went wrong trying to initialize the pairing key. \(underlyingError?.localizedDescription ?? "")"
        case .setClaims(let underlyingError):
            return "Something went wrong attempting to set claims. \(underlyingError?.localizedDescription ?? "")"
        case .photoCount(let underlyingError):
            return "Something went wrong trying to get the photo count. \(underlyingError?.localizedDescription ?? "")"
        case .deletePhoto(let underlyingError):
            return "Something went wrong deleting photo. \(underlyingError?.localizedDescription ?? "")"
        case .fetchPhotos(let underlyingError):
            return "Something went wrong fetching complete photos. \(underlyingError?.localizedDescription ?? "")"
        case .subscribeError(let underlyingError):
            return "Something went wrong subscribing to pairing key topic. \(underlyingError?.localizedDescription ?? "")"
        case .authError(let underlyingError):
            return "Something went wrong signing in user anonymously. \(underlyingError?.localizedDescription ?? "")"
        case .unsubscribeError(let underlyingError):
            return "Error unsubscribing from pairing key. \(underlyingError?.localizedDescription ?? "")"
        }
    }
}
