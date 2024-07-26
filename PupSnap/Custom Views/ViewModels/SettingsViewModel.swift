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
    @Published var pushNotifs: Bool
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
        self.pushNotifs = PersistenceManager.notificationStatus()
        self.dog = LaunchManager.shared.dog
        
        self.selectedPhoto = dog?.photo
        self.dogName = dog?.name ?? "Default"
        self.newDogName = dogName
    }
    
    init(pairingKey: Int) {
        self.pushNotifs = PersistenceManager.notificationStatus()
        self.dog = LaunchManager.shared.dog
        
        self.selectedPhoto = dog?.photo
        self.dogName = dog?.name ?? "Default"
        self.newDogName = dogName
        self.newKey = String(pairingKey)
        self.comingFromBranchLink = true
    }
    
    init(pairingKey: Int, firstTimeLaunch: Bool) {
        self.pushNotifs = PersistenceManager.notificationStatus()
        self.dog = LaunchManager.shared.dog
        
        self.selectedPhoto = dog?.photo
        self.dogName = dog?.name ?? "Default"
        self.newDogName = dogName
        
        self.newKey = String(pairingKey)
        self.firstTimeLaunch = firstTimeLaunch
    }
    
    func changeKey() async throws {
        do {
            let keyExists = try await NetworkManager.shared.checkIfKeyExists(key: newKey)
            
            if !keyExists {
                self.alertMessage = PSError.invalidKey(underlyingError: nil).localizedDescription
                throw PSError.invalidKey()
            }
            
            guard let newKeyInt = Int(newKey) else { return }
            
            do {
                try await PersistenceManager.changeKey(to: newKeyInt)
                userKey = newKeyInt
            } catch {
                self.alertMessage = PSError.setClaims(underlyingError: error).localizedDescription
                throw PSError.setClaims()
            }
        } catch {
            print("Something went wrong: \(error)")
            throw error
        }
    }

    
    func subscribeToBranchKey() async throws {
        guard let newKey = Int(self.newKey) else {
            self.alertMessage = PSError.invalidKey(underlyingError: nil).localizedDescription
            throw PSError.invalidKey(underlyingError: nil)
        }
        
        try await PersistenceManager.branchKeySetup(key: newKey)
        userKey = newKey
        try await LaunchManager.shared.refreshToken()
        try await updateDog()
        LaunchManager.shared.showToast = true
        PersistenceManager.setupDone()
        firstTimeLaunch = false
        AppDelegate.setupCompletionSubject.send(())
    }
    
    func updateDog() async throws {
        await LaunchManager.shared.setDog()
    }
    
    func updateDogPhoto() async {
        if newPhoto != "" {
            NetworkManager.shared.changeDogPhoto(to: newPhoto)
            showPhotoChangeSuccess = true
            await LaunchManager.shared.setDog()
        }
    }
    
    func updateDogName() async {
        if newDogName != "" {
            NetworkManager.shared.changeDogName(to: newDogName)
            dogNameSuccess = true
            await LaunchManager.shared.setDog()
        }
    }
    
    func updateAppForNewKey() async throws {
        try await changeKey()
        try await updateDog()
        LaunchManager.shared.showToast = true
        LaunchManager.shared.launchingFromBranchLink = false      
        LaunchManager.shared.branchPasteboardInstall = false
    }
    
   
}
