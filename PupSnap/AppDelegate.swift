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
    static let standardSceneSetup = PassthroughSubject<Void, Never>()
    static let branchDeepLinkEvent = PassthroughSubject<Int, Never>()
    static let notificationSubject = PassthroughSubject<Void, Never>()
    static let branchFirstTimeLaunch = PassthroughSubject<Int, Never>()
    static let regularFirstTimeLaunch = PassthroughSubject<Void, Never>()
    static let branchPasteboardEvent = PassthroughSubject<Void, Never>()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //list all fonts available
//        for family: String in UIFont.familyNames {
//            print(family)
//            for names: String in UIFont.fontNames(forFamilyName: family) {
//                print("== \(names)")
//            }
//        }
        
        
        // Override point for customization after application launch.
#if DEBUG
        let providerFactory = AppCheckDebugProviderFactory()
#else
        let providerFactory = YourSimpleAppCheckProviderFactory()
#endif
        AppCheck.setAppCheckProviderFactory(providerFactory)
        
        FirebaseApp.configure()    
        
        //FCM and APNS Messaging config
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        print("register for remote notifications call in app delegate")
        application.registerForRemoteNotifications()
    
        
        let setupDone = PersistenceManager.setupStatus()
        //uncomment these 2 lines to force branch install
        //        LaunchManager.shared.branchPasteboardInstall = true
        //        UIPasteboard.general.url = URL(string:"https://pupsnap-alternate.app.link/iYSReGVhjLb?__branch_flow_type=viewapp&__branch_flow_id=1345084269039655716&__branch_mobile_deepview_type=1&nl_opt_in=1&_cpts=1721931307629")!
        
        if !setupDone {
            if BNCPasteboard.sharedInstance().isUrlOnPasteboard() {
                print("url was on pasteboard")
                LaunchManager.shared.launchType = .branchFirstLaunch
            } else {
                print("launch type onboarding")
                LaunchManager.shared.launchType = .onboardingFirstLaunch
            }
        } else {
            print("launch type was standard returning")
            LaunchManager.shared.launchType = .standardReturningLaunch
            // Request notification permissions
           requestNotificationPermissions()
        }
        
        
        BranchScene.shared().initSession(launchOptions: launchOptions, registerDeepLinkHandler: { (params, error, scene) in
            print("checking branch params")
            LaunchManager.shared.checkBranchParams(params)
        })
        
        print("end of app delegate")
        return true
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
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("didregisterforremnote notifications and set apns token")
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: any Error) {
        print("failed to reegister for remote nofgiciations with error \(error)")
    }
    
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("messaging didRecieveRegistrationToken")
        Messaging.messaging().token { token, error in
          if let error = error {
            print("Error fetching FCM registration token: \(error)")
          } else if let _ = token {
            print("FCM registration token was succesful")
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
        print("app delegate rceived notification")


            LaunchManager.shared.pushUserInfo = userInfo
            LaunchManager.shared.openFromPush = true
        if LaunchManager.shared.launchFromBackground {
            AppDelegate.notificationSubject.send(())
        }
        
       
    }
}
