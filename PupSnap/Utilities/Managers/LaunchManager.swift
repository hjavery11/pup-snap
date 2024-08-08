//
//  LaunchManager.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/19/24.
//

import UIKit
import FirebaseAuth
import BranchSDK
import FirebaseCrashlytics

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
    var photoVCLoaded: Bool = false
    
    var openFromPush: Bool = false
    
    var pushUserInfo = [AnyHashable: Any]()
    
    var dogChanged: Bool = false
    
    var showToast: Bool = false
    
    var sharedPairingKey: Int?
    var onboardingPairingKey: Int?
    var mainVCLoaded: Bool = false
    
    var dog: Dog?
    
    var shareURL: String?
    
    private init() {}
    
    func determineLaunch() {        
        switch launchType {
        case .branchFirstLaunch:
            AppDelegate.branchPasteboardEvent.send(())
        case .branchDeepLink:
            print("branch returning launch")
            showBranchPairingView()
        case .onboardingFirstLaunch:
            AppDelegate.regularFirstTimeLaunch.send(())
        case .standardReturningLaunch:
            if verifyReturningLaunch() {
                AppDelegate.standardSceneSetup.send(())
            } else {
                AppDelegate.regularFirstTimeLaunch.send(())
            }
        case nil:
            print("should never be nil, but launch type was nil")
            AppDelegate.standardSceneSetup.send(())
        }
       
    }
    
    func verifyReturningLaunch() -> Bool {
        let userKey = PersistenceManager.retrieveKey()
        if userKey == 0 {
            //key was 0 during returning launch which is bad, so reset to onboarding flow
            PersistenceManager.unsetKey()
            return false
        } else {
            return true
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
            Crashlytics.crashlytics().log("Error during returningLaunchSetup in launch mannager with error: \(error)")
            Crashlytics.crashlytics().record(error: error)
            throw PSError.fetchDogError(underlyingError: error)
        }
    }
    
    func requestNotificationPermissions() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification permissions: \(error)")
                return
            }
            
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                    if UserDefaults.standard.object(forKey: PersistenceManager.Keys.notification) == nil {
                        PersistenceManager.enableNotifications()
                    }
                }
            } else {
                print("Notification permissions denied.")
                if UserDefaults.standard.object(forKey: PersistenceManager.Keys.notification) == nil {
                    PersistenceManager.disableNotifications()
                }
            }
        }
    }

    func finishOnboarding(with dog: Dog) async throws {
        //first get new key and auth
        do {
           let _ = try await Auth.auth().signInAnonymously()
        } catch {
            Crashlytics.crashlytics().log("Error during onboardingSetup in Launchmanager during auth sign in with error: \(error)")
            Crashlytics.crashlytics().record(error: error)
            throw PSError.onboardingError(underlyingError: error)
        }
        
        do {
            let newKey = try await NetworkManager.shared.getNewKey()
            if newKey != 0 {
                self.onboardingPairingKey = newKey
            } else {
                throw PSError.onboardingError(underlyingError: nil)
            }
        } catch {
            Crashlytics.crashlytics().log("Error during onboardingSetup in Launchmanager during get new key with error: \(error)")
            Crashlytics.crashlytics().record(error: error)
            throw PSError.onboardingError(underlyingError: error)
        }
        
        guard let pairingKey = self.onboardingPairingKey else {
            print("No onboarding pairing key found, cant finish onboarding")
            throw PSError.onboardingError(underlyingError: nil)
        }
        
        // initalize the key which is a firebase function that creates an empty object in the datbaase so the user has access to it
        PersistenceManager.setKey(to: pairingKey)
        
        do {
            try await NetworkManager.shared.initializeKey(pairingKey: pairingKey)
            try await NetworkManager.shared.setClaims(with: pairingKey)
            try await PersistenceManager.subscribeToPairingKey(pairingKey: pairingKey)
        } catch {
            Crashlytics.crashlytics().log("Issue in finishOnboarding in LaunchManager during the onboarding setup process. Error returned was \(error)")
            Crashlytics.crashlytics().record(error: error)
            throw PSError.onboardingError(underlyingError: error)
        }
        
        do {
            try await self.refreshToken()
        } catch {
            print("Error refreshing onbaording token")
        }
      
        do {
            try await NetworkManager.shared.setDog(to: dog)
        } catch {
            throw PSError.onboardingError(underlyingError: error)
        }
        
        self.dog = dog
        
        print("Onboarding complete for key: \(pairingKey) and dog \(dog)")
        
        DispatchQueue.main.async {
            AppDelegate.standardSceneSetup.send(())
        }
    }
    
    func refreshToken() async throws {
        print("attempting to refresh token")
        do {
            let tokenResult = try await Auth.auth().currentUser?.getIDTokenResult(forcingRefresh: true)
            print(tokenResult?.token.count ?? "token.count returned  nil")
            print("refreshed token")
        } catch {
            print("error occured during token refresh")
            throw PSError.authError(underlyingError: error)
        }
    }
    
    func setDog() async throws{
            do {
                self.dog = try await NetworkManager.shared.fetchDog()
                self.dogChanged = true
                
            } catch {
                print("Error fetching and setting dog in launch manager: \(error)")
                NetworkManager.shared.logError("Error during setDog in Launchmanager during auth sign in with error: \(error)", error: error)
                throw PSError.fetchDogError(underlyingError: error)
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
                
                if mainVCLoaded || !PersistenceManager.setupStatus() {
                    showBranchPairingView()
                } 
            
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
            Crashlytics.crashlytics().log("Error during standardSetup in Launchmanager during auth sign in")
        } catch PSError.fetchDogError(let error){
            print("fetch dog error")
            print(error?.localizedDescription ?? "no localized description for fetch dog error")
            Crashlytics.crashlytics().log("Error during onboardingSetup in Launchmanager during fetch dog")
        }
        
        // Remote config setup
        print("returning-remote config-3rd")
        do {
            try await RemoteConfigManager.shared.fetchAndActivate()
            print("remote config done")
        } catch {
            print("Error on remote config setup: \(error)")
            Crashlytics.crashlytics().log("Error during fetch of remote config in launch config with error: \(error)")
            Crashlytics.crashlytics().record(error: error)
        }
    }
}
