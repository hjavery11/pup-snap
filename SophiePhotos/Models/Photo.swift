//
//  Photo.swift
//  SophiePhotos
//
//  Created by Harrison Javery on 7/5/24.
//

import UIKit

struct Photo: Hashable {
    let caption: String
    let ratings: [Rating]
    let id: String
    var image: UIImage
    var imagePath: String?
    var timestamp: Int
    
    struct Rating: Hashable {
        let user: String
        let rating: Int
    }
    
    mutating func setFilePath(to imagePath: String) {
        self.imagePath = imagePath
    }    
    
}



