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

