//
//  Photo.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/5/24.
//

import UIKit

class Photo: Decodable {

    let caption: String
    var ratings: [String: Int]
    let timestamp: Int
    var image: UIImage?
    private var _id: String?
    
    var id: String {
        get {
            return _id ?? ""
        }
        set {
            _id = newValue
        }
    }
    
    init(caption: String, ratings: [String : Int], timestamp: Int, path: String? = nil, image: UIImage? = nil, id: String) {
        self.caption = caption
        self.ratings = ratings
        self.timestamp = timestamp
        self.image = image
        self._id = id
    }
    
    func addRating(user: String, rating: Int) {
        ratings.updateValue(rating, forKey: user)
    }
    
    
    
    private enum CodingKeys: String, CodingKey {
        case caption, ratings, timestamp
    }
   
    
}

typealias PhotoDictionary = [String: Photo]

extension Photo : Comparable {
    static func < (lhs: Photo, rhs: Photo) -> Bool {
        if lhs.timestamp != rhs.timestamp {
            return lhs.timestamp > rhs.timestamp
        } else {
            return lhs.id > rhs.id
        }
    }
   
}

extension Photo {
    var averageRating: Int {
        let totalRatings = ratings.values.reduce(0, +)
        return Int(ratings.isEmpty ? 0.0 : Double(totalRatings) / Double(ratings.count).rounded())
    }
    var userRating: Int {
        let user = PersistenceManager.retrieveID()
        return ratings[user] ?? 0
    }
    
}

extension Photo: Hashable {
    static func == (lhs:Photo, rhs: Photo) -> Bool {
        ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
