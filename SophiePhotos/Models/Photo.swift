//
//  Photo.swift
//  SophiePhotos
//
//  Created by Harrison Javery on 7/5/24.
//

import UIKit

struct Photo: Decodable, Hashable {

    let caption: String
    let ratings: [String: Int]
    let timestamp: Int
    var path: String?
    var image: UIImage?
    var id: String?
    
    private enum CodingKeys: String, CodingKey {
        case caption, ratings, timestamp, path
    }
    
    mutating func setImage(to image: UIImage) {
        self.image = image
    }
    
    mutating func setID(_ newID: String) {
        self.id = newID
    }
    
    mutating func setPath(_ path: String) {
        self.path = path
    }
    
}

typealias PhotoDictionary = [String: Photo]

extension Photo : Comparable {
    static func < (lhs: Photo, rhs: Photo) -> Bool {
        if lhs.timestamp != rhs.timestamp {
            return lhs.timestamp > rhs.timestamp
        } else {
            return lhs.id ?? "" > rhs.id ?? ""
        }
    }
}

extension Photo {
    var averageRating: Int {
        let totalRatings = ratings.values.reduce(0, +)
        return Int(ratings.isEmpty ? 0.0 : Double(totalRatings) / Double(ratings.count).rounded())
    }
}
