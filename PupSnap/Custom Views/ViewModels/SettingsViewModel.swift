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
    @Published var isLoading: Bool = false
    
    //dog view
    @Published var showIconConfirmation: Bool = false
    @Published var showPhotoChangeSuccess: Bool = false
    @Published var selectedPhoto: String?
    @Published var newPhoto: String = ""
    @Published var dogName: String
    @Published var dogNameSuccess: Bool = false
    @Published var showNameConfirmation: Bool = false
    @Published var newDogName: String = ""
    var alertMessage: String = ""
    @Published var userKey = PersistenceManager.retrieveKey()
    var comingFromBranchLink: Bool = false
    var firstTimeLaunch: Bool = false
    
    var dog: Dog?
    
    
    
    init() {
        self.dog = LaunchManager.shared.dog
        
        self.selectedPhoto = dog?.photo
        self.dogName = dog?.name ?? "Default"
        self.newDogName = dogName
    }
    
    init(pairingKey: Int) {
        self.dog = LaunchManager.shared.dog
        
        self.selectedPhoto = dog?.photo
        self.dogName = dog?.name ?? "Default"
        self.newDogName = dogName
        self.newKey = String(pairingKey)
        self.comingFromBranchLink = true
    }
    
    init(pairingKey: Int, firstTimeLaunch: Bool) {
        self.dog = LaunchManager.shared.dog
        
        self.selectedPhoto = dog?.photo
        self.dogName = dog?.name ?? "Default"
        self.newDogName = dogName
        
        self.newKey = String(pairingKey)
        self.firstTimeLaunch = firstTimeLaunch
    }
    
    func changeKey() async throws {
        //TODO: Change this to use a function in the cloud to check the new key so people cant sniff out all keys
       let allKeys = try await NetworkManager.shared.retrieveAllKeys()
        guard let newKey = Int(self.newKey) else {            
            self.alertMessage = PSError.invalidKey(underlyingError: nil).localizedDescription
            throw PSError.invalidKey(underlyingError: nil)
        }
        if allKeys.contains(newKey) {
            self.userKey = newKey
            do {
                try await PersistenceManager.changeKey(to: newKey)  
                let newDog = try await NetworkManager.shared.fetchDogForKey(newKey)
                LaunchManager.shared.setDog()
     
            } catch {
                self.alertMessage = PSError.setClaims(underlyingError: error).localizedDescription
                throw PSError.setClaims()
            }
        } else {
            self.alertMessage = PSError.invalidKey(underlyingError: nil).localizedDescription
            throw PSError.invalidKey()
        }
    }
    
    func subscribeToBranchKey() async throws {
        guard let newKey = Int(self.newKey) else {
            self.alertMessage = PSError.invalidKey(underlyingError: nil).localizedDescription
            throw PSError.invalidKey(underlyingError: nil)
        }
        
        try await PersistenceManager.branchKeySetup(key: newKey)
    }
    
    func updateDog() async throws {
        guard let newKey = Int(self.newKey) else {
            self.alertMessage = PSError.invalidKey(underlyingError: nil).localizedDescription
            throw PSError.invalidKey(underlyingError: nil)
        }
        
        do {
            let newDog = try await NetworkManager.shared.fetchDogForKey(newKey)
            LaunchManager.shared.setDog()
        } catch {
            print("Could not get new dog for pairing key: \(error)")
        }
            
    }
    
    func updateDogPhoto() {
        if newPhoto != "" {
            NetworkManager.shared.changeDogPhoto(to: newPhoto)
            showPhotoChangeSuccess = true
            LaunchManager.shared.setDog()
        }
    }
    
    func updateDogName() {        
        if newDogName != "" {
            NetworkManager.shared.changeDogName(to: newDogName)
            dogNameSuccess = true
            LaunchManager.shared.setDog()
        }
    }
    
}
