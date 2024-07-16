//
//  SettingsViewModel.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/15/24.
//

import Foundation

@MainActor class SettingsViewModel: ObservableObject {     
    
     let dogPhotos: [String] = [
        "sophie-iso",
        "australian-shephard-1",
        "australian-shephard-2",
        "beagle-1",
        "chihuahua-black",
        "chihuahua-brown",
        "cream-lab",
        "black-lab-1",
        "french-bulldog-black",
        "french-bulldog-brown",
        "french-bulldog-gray",
        "german-shepherd",
        "golden-retriever-2",
        "golden-retriever",
        "labradoodle",
        "pitbull-brown",
        "pitbull-gray",
        "poodle-brown",
        "poodle-white",
        "rottweiler-1"
    ]

    
    @Published var showingChangeKey: Bool = false
    @Published var newKey: String = ""
    @Published var showingConfirmation: Bool = false
    @Published var newKeyError: Bool = false
    @Published var showingChangeKeyError: Bool = false
    @Published var pushNotifs: Bool = true
    
    //dog view
    @Published var showIconConfirmation: Bool = false
    @Published var showIconSuccess: Bool = false
    @Published var selectedPhoto: String?
    @Published var newPhoto: String = ""
    @Published var dogName: String
    @Published var dogNameSuccess: Bool = false
    @Published var showNameConfirmation: Bool = false
    @Published var newDogName: String = ""
    
    init() {
        self.selectedPhoto = PersistenceManager.getDogPhoto() ?? "sophie-iso"
        self.dogName = PersistenceManager.getDogName() ?? ""
        self.newDogName = dogName
    }
    
    var alertMessage: String = ""
    
    @Published var userKey = PersistenceManager.retrieveKey()
    
    func changeKey() async throws {
       let allKeys = try await NetworkManager.shared.retrieveAllKeys()
        guard let newKey = Int(self.newKey) else {            
            self.alertMessage = SophieError.invalidKey.rawValue
            throw SophieError.invalidKey
        }
        if allKeys.contains(newKey) || newKey == 123456 {
            self.userKey = newKey
            PersistenceManager.setKey(key: newKey)
        } else {
            self.alertMessage = SophieError.invalidKey.rawValue
            throw SophieError.invalidKey
        }
    }
    
    func updateDogPhoto() {
        if self.newPhoto != "" {
            PersistenceManager.updateDogPhoto(photo: self.newPhoto)
            showIconSuccess = true
         
        }
    }
    
    func updateDogName() {
        if self.newDogName != "" {
            PersistenceManager.setDogName(to: self.newDogName)
            dogNameSuccess = true
            self.dogName = newDogName
        }
    }

    
}
