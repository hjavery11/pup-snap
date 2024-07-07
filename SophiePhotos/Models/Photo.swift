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
    let path: String
    var image: UIImage?
    
    private enum CodingKeys: String, CodingKey {
        case caption, ratings, timestamp, path
    }
    
    mutating func setImage(to image: UIImage) {
        self.image = image
    }
}

typealias PhotoDictionary = [String: Photo]

