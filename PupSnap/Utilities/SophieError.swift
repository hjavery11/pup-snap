//
//  SophieError.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/5/24.
//

import Foundation

enum SophieError: String, Error {
    case localdata = "Error accessing local data"
    case photoAccess = "We couldnt find a photo in the database. Please try again."
    case invalidKey = "The pairing key you entered does not exist. Please double check your info."
    
}
