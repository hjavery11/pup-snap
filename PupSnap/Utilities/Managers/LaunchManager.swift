//
//  LaunchManager.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/19/24.
//

import UIKit
import FirebaseAuth

class LaunchManager {
    
    static let shared = LaunchManager()
    
    var hasFinishedUserLaunchSetup: Bool = false
    var hasFinishedSceneLaunchSetup: Bool = false
    var launchingFromBranchLink: Bool = false
    var launchingFromPushNotification: Bool = false
    var firstTimeLaunch: Bool = false
    var openFromPush: Bool = false
    var pushUserInfo = [AnyHashable: Any]()
    
    var didOnboard: Bool = false
    
    var showToast: Bool = false
    
    var sharedPairingKey: Int?
    var onboardingPairingKey: Int?
    
    var dog: Dog?
    
    private init() {}
    
    func branchSetup() {
        guard let sharedPairingKey = self.sharedPairingKey else { return }
        if sharedPairingKey != PersistenceManager.retrieveKey() { // handling weird case where after app applies the change and is reopened, it still tries to change the key again
            if hasFinishedUserLaunchSetup && launchingFromBranchLink && hasFinishedSceneLaunchSetup{
                AppDelegate.branchLinkSubject.send(sharedPairingKey)
            }
        }
    }
    
    func branchFirstTimeLaunch(_ key: Int) {
        AppDelegate.branchFirstTimeLaunch.send(key)
    }
    
    func cleanup() {
        self.firstTimeLaunch = false
        UIPasteboard.remove(withName: .general)
    }
    
    func showPushPhoto() {
        if hasFinishedUserLaunchSetup && hasFinishedSceneLaunchSetup && openFromPush {
            AppDelegate.notificationSubject.send(())
        }
    }
    
    func launchSetup() async throws {
        // do things here for returning users
        let authResult = try await Auth.auth().signInAnonymously()
        let user = authResult.user
        try await user.getIDTokenResult(forcingRefresh: true)
        self.dog = try await NetworkManager.shared.fetchDog()
    }
    
    func launchOnboarding() {
        Task {
            // do user setup
           try await Auth.auth().signInAnonymously()
        }
        //get a key in background
        Task {
            let allKeys = try await NetworkManager.shared.retrieveAllKeys()
            guard !allKeys.isEmpty else {
                print("No keys returned from database. Exiting launch")
                return
            }
            //generate new 8-digit int key not in current keys
            var newKey: Int
            repeat {
                newKey = Int.random(in: 10000000...99999999)
            } while allKeys.contains(newKey)
            
            self.onboardingPairingKey = newKey
            
        }
        
        AppDelegate.regularFirstTimeLaunch.send(())
        
//        
//        //@TODO: Update this to move the generating of the key to the server and return back the new key to avoid people being able to see all keys
//        Task {
//            let allKeys = try await NetworkManager.shared.retrieveAllKeys()
//            guard !allKeys.isEmpty else {
//                print("No keys returned from database. Exiting launch")
//                return
//            }
//            //generate new 8-digit int key not in current keys
//            var newKey: Int
//            repeat {
//                newKey = Int.random(in: 10000000...99999999)
//            } while allKeys.contains(newKey)
//            //save key to user defaults
//            PersistenceManager.setKey(to: newKey)
//            print("New user key set to :\(newKey)")
//            // initalize the key which is a firebase function that creates an empty object in the datbaase so the user has access to it
//            try await NetworkManager.shared.initializeKey(pairingKey: newKey)
//            try await NetworkManager.shared.setClaims(with: newKey)
//            
//            let newDog = Dog(photo: "black-lab-1", name: "Lucky")
//            try await NetworkManager.shared.setDog(to: newDog)
//            self.dog = newDog
//            //end of user setup. Should now have claims setup to be able to access database
//        }
    }
    
    func finishOnboarding(with dog: Dog) async throws {
        guard let pairingKey = self.onboardingPairingKey else {
            print("No onboarding pairing key found, cant finish onboarding")
            return
        }
        
        // initalize the key which is a firebase function that creates an empty object in the datbaase so the user has access to it
        PersistenceManager.setKey(to: pairingKey)
        try await NetworkManager.shared.initializeKey(pairingKey: pairingKey)
        try await NetworkManager.shared.setClaims(with: pairingKey)
        try await PersistenceManager.subscribeToPairingKey(pairingKey: pairingKey)
        do {
            try await self.refreshToken()
        } catch {
            print("Error refreshing onbaording token")
        }
      
        
        try await NetworkManager.shared.setDog(to: dog)
        self.dog = dog
        
        print("Onboarding complete for key: \(pairingKey) and dog \(dog)")
        
        DispatchQueue.main.async {
            AppDelegate.setupCompletionSubject.send(())
            self.didOnboard = true
        }
    }
    
    func refreshToken() async throws {
       try await Auth.auth().currentUser?.getIDTokenResult(forcingRefresh: true)
    }
}
