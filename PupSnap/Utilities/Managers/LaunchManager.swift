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
    
    enum LaunchType {
        case branchFirstLaunch,branchDeepLink,onboardingFirstLaunch,standardReturningLaunch
    }
    
    var launchType: LaunchType?
    
    let imageURL = "https://pupsnapapp.com/pupsnap-icon.png"
    
    var hasFinishedUserLaunchSetup: Bool = false
    var hasFinishedSceneLaunchSetup: Bool = false
    var launchingFromBranchLink: Bool = false
    var launchingFromPushNotification: Bool = false
    var firstTimeLaunch: Bool = false
    var launchFromBackground: Bool = false
    
    var openFromPush: Bool = false
    
    var pushUserInfo = [AnyHashable: Any]()
    
    var dogChanged: Bool = false
    
    var showToast: Bool = false
    
    var sharedPairingKey: Int?
    var onboardingPairingKey: Int?
    
    var dog: Dog?
    
    var shareURL: String?
    
    private init() {}
    
    func determineLaunch() {
        switch launchType {
        case .branchFirstLaunch:
            AppDelegate.branchPasteboardEvent.send(())
        case .branchDeepLink:
            print("branch returning launch")
            //not sure about this one yet, will see if it gets called
        case .onboardingFirstLaunch:
            onboardingSetup()
            AppDelegate.regularFirstTimeLaunch.send(())
        case .standardReturningLaunch:
            AppDelegate.standardSceneSetup.send(())
        case nil:
            print("should never be nil, but launch type was nil")
            AppDelegate.standardSceneSetup.send(())
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
    
    func onboardingSetup() {
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
            AppDelegate.standardSceneSetup.send(())
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
                if let pairingKeyInt = pairingKey as? Int {
                    self.sharedPairingKey = pairingKeyInt
                } else if let pairingKeyString = pairingKey as? String {
                    self.sharedPairingKey = Int(pairingKeyString)
                }
                self.launchType = .branchDeepLink
                showBranchPairingView()
            }
    }
    
    func showBranchPairingView() {
        guard let sharedPairingKey = self.sharedPairingKey else { return }
        if sharedPairingKey != PersistenceManager.retrieveKey() { // handling weird case where after app applies the change and is reopened, it still tries to change the key again
            AppDelegate.branchDeepLinkEvent.send(sharedPairingKey)
        }
    }
    
    func runStandardSetup() async throws{
        print("returning-runStandardsetup")
        do {
            try await returningLaunchSetup()
            
            LaunchManager.shared.hasFinishedUserLaunchSetup = true
            print("launchSetup done, sending to scene setup")
            
        } catch PSError.authError(let error){
            print("Auth error")
            print(error?.localizedDescription ?? "no localized description for auth error")
        } catch PSError.fetchDogError(let error){
            print("fetch dog error")
            print(error?.localizedDescription ?? "no localized description for fetch dog error")
        }
        
        // Remote config setup
        print("returning-remote config-3rd")
        do {
            try await RemoteConfigManager.shared.fetchAndActivate()
            print("remote config done")
        } catch {
            print("Error on remote config setup: \(error)")
        }
    }
}
