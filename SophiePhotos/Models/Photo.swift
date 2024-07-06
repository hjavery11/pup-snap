//
//  Photo.swift
//  SophiePhotos
//
//  Created by Harrison Javery on 7/5/24.
//

import UIKit

struct Photo {
    let caption: String
    let ratings: [Rating]
    let id: String
    let image: UIImage
    var imagePath: String?
    
    struct Rating {
        let user: String
        let rating: Int
    }
    
    mutating func setFilePath(to imagePath: String) {
        self.imagePath = imagePath
    }
}



