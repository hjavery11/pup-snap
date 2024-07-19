//
//  SettingsViewModel.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/15/24.
//

import Foundation

@MainActor class SettingsViewModel: ObservableObject {     
    
     @Published var dogPhotos: [String] = [
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
    @Published var showingPairingConfirmation: Bool = false
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
    var alertMessage: String = ""
    @Published var userKey = PersistenceManager.retrieveKey()
    var shareConfirmationMessage: Bool = false
    
    init() {
        self.selectedPhoto = PersistenceManager.getDogPhoto() ?? "sophie-iso"
        self.dogName = PersistenceManager.getDogName() ?? ""
        self.newDogName = dogName
        
        print("user key is \(userKey)")
    }
    
    init(pairingKey: Int) {
        self.selectedPhoto = PersistenceManager.getDogPhoto() ?? "sophie-iso"
        self.dogName = PersistenceManager.getDogName() ?? ""
        self.newDogName = dogName
        self.newKey = String(pairingKey)
        self.showingPairingConfirmation = true
        self.shareConfirmationMessage = true
        
        print("user key is \(userKey)")
    }
    
   
    
   

    
    func changeKey() async throws {
       let allKeys = try await NetworkManager.shared.retrieveAllKeys()
        guard let newKey = Int(self.newKey) else {            
            self.alertMessage = PSError.invalidKey(underlyingError: nil).localizedDescription
            throw PSError.invalidKey(underlyingError: nil)
        }
        if allKeys.contains(newKey) {
            self.userKey = newKey
            PersistenceManager.unsetKey()
            PersistenceManager.setKey(to: newKey)
            do {
                try await PersistenceManager.changeKey(to: newKey)            
            } catch {
                self.alertMessage = PSError.setClaims(underlyingError: error).localizedDescription
                throw PSError.setClaims()
            }
        } else {
            self.alertMessage = PSError.invalidKey(underlyingError: nil).localizedDescription
            throw PSError.invalidKey()
        }
    }
    
    func updateDogPhoto() {
        if self.newPhoto != "" {
            PersistenceManager.updateDogPhoto(photo: self.newPhoto)
            showIconSuccess = true
            self.dogPhotos.removeAll {
                $0 == newPhoto
            }
            if let photo = PersistenceManager.getDogPhoto() {
                self.dogPhotos.append(photo)
            }
            
         
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
