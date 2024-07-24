//
//  AppDelegate.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/1/24.
//

import UIKit
import Firebase
import UserNotifications
import FirebaseAppCheck
import FirebaseCore
import FirebaseAuth
import FirebaseMessaging
import FirebaseFunctions
import BranchSDK
import Combine

@main
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {
    
    var window: UIWindow?
    static let setupCompletionSubject = PassthroughSubject<Void, Never>()
    static let branchLinkSubject = PassthroughSubject<Int, Never>()
    static let notificationSubject = PassthroughSubject<Void, Never>()
    static let branchFirstTimeLaunch = PassthroughSubject<Int, Never>()
    static let regularFirstTimeLaunch = PassthroughSubject<Void, Never>()
    static let branchPasteBoardTesting = PassthroughSubject<Void, Never>()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //set default font for app
//        for family in UIFont.familyNames.sorted() {
//            let names = UIFont.fontNames(forFamilyName: family)
//            print("Family: \(family) Font names: \(names)")
//        }
        
        // Override point for customization after application launch.
#if DEBUG
        let providerFactory = AppCheckDebugProviderFactory()
#else
        let providerFactory = YourSimpleAppCheckProviderFactory()
#endif
        AppCheck.setAppCheckProviderFactory(providerFactory)
        
        FirebaseApp.configure()
        
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        application.registerForRemoteNotifications()
        
        let setupDone = UserDefaults.standard.bool(forKey: PersistenceManager.Keys.setupComplete)
        
        if !setupDone {
            BNCPasteboard.sharedInstance().checkOnInstall = true
            if BNCPasteboard.sharedInstance().isUrlOnPasteboard() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    AppDelegate.branchPasteBoardTesting.send(())
                }
                return true
            }
        }
        
        initializeBranch(launchOptions)
        
        let userKey = PersistenceManager.retrieveKey()
        
        if userKey == 0 {
            runOnboardingSetup()
        } else {
            runStandardSetup()
        }
        
        return true
    }
    
    private func runStandardSetup() {
        Task {
            do {
                try await LaunchManager.shared.launchSetup()
                // Request notification permissions
                requestNotificationPermissions()
                LaunchManager.shared.hasFinishedUserLaunchSetup = true
                
                AppDelegate.setupCompletionSubject.send(())
                
            } catch {
                print("Error requesting authorization to UNUserNotiacationCenter with error: \(error)")
            }
        }
        
        // Remote config setup
        Task {
            do {
                try await RemoteConfigManager.shared.fetchAndActivate()
            } catch {
                print("Error on remote config setup: \(error)")
            }
        }
    }
    
    private func runOnboardingSetup() {
        Task {
            LaunchManager.shared.launchOnboarding()
        }
    }
    
    func initializeBranch(_ launchOptions:[UIApplication.LaunchOptionsKey: Any]? ) {
        // Initialize Branch session
        Branch.getInstance().initSession(launchOptions: launchOptions) { (params, error) in
            if let params = params as? [String: AnyObject], let pairingKeyValue = params["pairingKey"] {
                if let sharedPairingKey = pairingKeyValue as? Int {
                    LaunchManager.shared.launchingFromBranchLink = true
                    LaunchManager.shared.sharedPairingKey = sharedPairingKey
                    LaunchManager.shared.branchSetup()
                } else if let pairingKeyString = pairingKeyValue as? String, let sharedPairingKey = Int(pairingKeyString) {
                    LaunchManager.shared.launchingFromBranchLink = true
                    LaunchManager.shared.sharedPairingKey = sharedPairingKey
                    LaunchManager.shared.branchSetup()
                }
            }
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
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        Branch.getInstance().application(app, open: url, options: options)
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        Branch.getInstance().continue(userActivity)
        return true
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        Messaging.messaging().token { token, error in
          if let error = error {
            print("Error fetching FCM registration token: \(error)")
          } else if let token = token {
            print("FCM registration token: \(token)")
          }
        }
    }
    
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    // Notification receieved while in app (not clicked)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async
    -> UNNotificationPresentationOptions {
        let _ = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        //Messaging.messaging().appDidReceiveMessage(userInfo)
        
        
        print("did receieve notification while app launched")
        
        
        // Change this to your preferred presentation option
        //return [[.banner, .sound, .list]]
        return []
    }
    
    //notification clicked (while in app, unsure if backgrouded
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        
        // ...
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print full message.
        // print("printing from  last app delegate function : \(userInfo)")
        LaunchManager.shared.openFromPush = true
        LaunchManager.shared.pushUserInfo = userInfo
        LaunchManager.shared.showPushPhoto()
    }
}
