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
    static let notificationSubject = PassthroughSubject<[AnyHashable: Any], Never>()
    
    var launchedFromNotification = false
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        // Override point for customization after application launch.
#if DEBUG
        let providerFactory = AppCheckDebugProviderFactory()
        print("is debug")
#else
        let providerFactory = YourSimpleAppCheckProviderFactory()
        print("is not debug")
#endif
        AppCheck.setAppCheckProviderFactory(providerFactory)
        
        FirebaseApp.configure()
        
        print("delegatetest appdelegate didfinishlaunchingwithoptions")
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        
        application.registerForRemoteNotifications()
        
        // Check the pasteboard before Branch initialization
        Branch.getInstance().checkPasteboardOnInstall()
        //Should change to using UIPasteBoard instead of checkPasteboardOnInstall but skipping for now. Might be able to configure custom alert modal in the future
        
        // Initialize Branch session
        Branch.getInstance().initSession(launchOptions: launchOptions) { (params, error) in
            if let params = params as? [String: AnyObject], let pairingKeyValue = params["pairingKey"] {
                if let sharedPairingKey = pairingKeyValue as? Int {
                    print("handling pairing key branch param as Int: \(sharedPairingKey)")
                    AppDelegate.branchLinkSubject.send(sharedPairingKey)
                } else if let pairingKeyString = pairingKeyValue as? String, let sharedPairingKey = Int(pairingKeyString) {
                    print("handling pairing key branch param as String: \(sharedPairingKey)")
                    AppDelegate.branchLinkSubject.send(sharedPairingKey)
                } else {
                    print("Invalid pairing key format: \(pairingKeyValue)")
                    self.runStandardSetup()
                }
            } else {
                print("pairingKey not found in params")
                self.runStandardSetup()
            }
        }
        
        print("delegatetest end of did finish launching with options")
        return true
    }
    private func runStandardSetup() {
        if launchedFromNotification {
                   return
               }
        Task {
            do {
                try await PersistenceManager.launchSetup()
                print("launch setup complete. sending completion from app delegate to scene delegate")
                // Request notification permissions
                requestNotificationPermissions()
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
                }
            } else {
                print("Notification permissions denied.")
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //messaging setup
        Messaging.messaging().apnsToken = deviceToken
        print("Set apns token to fcm token in applicationdelegate didRegisterForRemoteNotificationsWithDeviceToken")
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
        guard let _ = fcmToken else {
            return
        }
        Task {
            do {
                let token = try await Messaging.messaging().token()
                print("FCM registration token: \(token)")
            } catch {
                print("Error fetching FCM registration token: \(error)")
            }
        }
    }
    
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        print("delegatetest app delegate new scene being created")
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func logToFile(_ message: String) {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        if let documentDirectory: NSURL = urls.first as NSURL? {
            let logFilePath = documentDirectory.appendingPathComponent("app.log")
            if let logFilePath = logFilePath {
                let logMessage = "\(Date()): \(message)\n"
                if fileManager.fileExists(atPath: logFilePath.path) {
                    if let fileHandle = try? FileHandle(forWritingTo: logFilePath) {
                        fileHandle.seekToEndOfFile()
                        fileHandle.write(logMessage.data(using: .utf8)!)
                        fileHandle.closeFile()
                    }
                } else {
                    try? logMessage.write(to: logFilePath, atomically: true, encoding: .utf8)
                }
            }
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    // Notification receieved while in app (not clicked)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async
    -> UNNotificationPresentationOptions {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        //Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // ...
        
        // Print full message.
        print("printing from  first app delegate function : \(userInfo)")
        
        
        // Change this to your preferred presentation option
        return [[.banner, .sound, .list]]
    }
    
    //notification clicked (while in app, unsure if backgrouded
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        
        // ...
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
            // Messaging.messaging().appDidReceiveMessage(userInfo)
       
        // Print full message.
        print("printing from  last app delegate function : \(userInfo)")
        AppDelegate.notificationSubject.send(userInfo)
    }
}
