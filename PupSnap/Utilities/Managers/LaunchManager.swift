//
//  LaunchManager.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/19/24.
//

import UIKit
import FirebaseAuth
import BranchSDK

class LaunchManager {
    
    static let shared = LaunchManager()
    
    let imageURL = "https://pupsnapapp.com/pupsnap-icon.png"
    
    var hasFinishedUserLaunchSetup: Bool = false
    var hasFinishedSceneLaunchSetup: Bool = false
    var launchingFromBranchLink: Bool = false
    var launchingFromPushNotification: Bool = false
    var firstTimeLaunch: Bool = false
    var openFromPush: Bool = false
    var pushUserInfo = [AnyHashable: Any]()
    
    var dogChanged: Bool = false
    
    var showToast: Bool = false
    
    var sharedPairingKey: Int?
    var onboardingPairingKey: Int?
    
    var dog: Dog?
    
    var shareURL: String?
    
    var branchPasteboardInstall: Bool = false
    
    private init() {}
    
    func branchSetup() {
        guard let sharedPairingKey = self.sharedPairingKey else { return }
        if sharedPairingKey != PersistenceManager.retrieveKey() { // handling weird case where after app applies the change and is reopened, it still tries to change the key again
            if hasFinishedUserLaunchSetup && launchingFromBranchLink && hasFinishedSceneLaunchSetup{
                AppDelegate.branchLinkSubject.send(sharedPairingKey)
            }
        }
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
    
    func returningLaunchSetup() async throws {
        // do things here for returning users
        do {
            try await Auth.auth().signInAnonymously()
            //potentially might need to call refreshToken() everytime, but for now hoping it is handled elsewhere to not make startup longer
        } catch {
            throw PSError.authError(underlyingError: error)
        }
        
        do {
            self.dog = try await NetworkManager.shared.fetchDog()
        } catch {
            throw PSError.fetchDogError(underlyingError: error)
        }
    }
    
    
    func launchOnboarding() {
        Task {
            // do user setup
           try await Auth.auth().signInAnonymously()
        }
        //get a key in background
        Task {
            let newKey = try await NetworkManager.shared.getNewKey()
            if newKey != 0 {
                self.onboardingPairingKey = newKey
            }
        }        
        
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
            self.dogChanged = true
        }
    }
    
    func refreshToken() async throws {
       try await Auth.auth().currentUser?.getIDTokenResult(forcingRefresh: true)
    }
    
    func setDog() async {
            do {
                self.dog = try await NetworkManager.shared.fetchDog()
                self.dogChanged = true
                
            } catch {
                print("Error fetching and setting dog in launch manager: \(error)")
            }
    }
    
    func initializePasteboardBranch() {
            Branch.getInstance().initSession() { (params, error) in
                if let params = params as? [String: AnyObject], let pairingKeyValue = params["pairingKey"] {
                    if !UserDefaults.standard.bool(forKey: PersistenceManager.Keys.setupComplete) {
                        if let sharedPairingKey = pairingKeyValue as? Int {
                            print("handling pairing key branch param as Int: \(sharedPairingKey)")
                            AppDelegate.branchFirstTimeLaunch.send(sharedPairingKey)
                        } else if let pairingKeyString = pairingKeyValue as? String, let sharedPairingKey = Int(pairingKeyString) {
                            print("handling pairing key branch param as String: \(sharedPairingKey)")
                            AppDelegate.branchFirstTimeLaunch.send(sharedPairingKey)
                            
                        }
                    }
            }
        }
    }
    
    func createBranchLink() {
        let key = PersistenceManager.retrieveKey()
        let buo = BranchUniversalObject(canonicalIdentifier: "pairing/\(key)")
        buo.title = "Join me on PupSnap!"
        buo.imageUrl = self.imageURL
        buo.contentMetadata.customMetadata["pairingKey"] = "\(key)"
        
        let lp = BranchLinkProperties()
      
        self.shareURL = buo.getShortUrl(with: lp)
    }
    
    func checkBranchParams(_ params: [AnyHashable: Any]?) {
        guard let params = params else { return }       
            if let pairingKey = params["pairingKey"] {
                print("Found pairing key from branch: \(pairingKey)")
                print(params)
                if let pairingKeyInt = pairingKey as? Int {
                    self.sharedPairingKey = pairingKeyInt
                } else if let pairingKeyString = pairingKey as? String {
                    self.sharedPairingKey = Int(pairingKeyString)
                }
                self.launchingFromBranchLink = true
                branchSetup()
            }
    
    }
}
