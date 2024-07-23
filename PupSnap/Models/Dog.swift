//
//  Dog.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/16/24.
//

import Foundation

class Dog: Codable {
    var photo: String
    var name: String
    
    init(photo: String, name: String) {
        self.photo = photo
        self.name = name
    }
    
    private enum CodingKeys: String, CodingKey {
        case photo, name
    }
    
}
