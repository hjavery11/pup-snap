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

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
     
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        #if DEBUG
        let providerFactory = AppCheckDebugProviderFactory()
        #else
        let providerFactory = YourSimpleAppCheckProviderFactory()
        #endif
        
        AppCheck.setAppCheckProviderFactory(providerFactory)
       
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        // Request for push notification permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            print("Permission granted: \(granted)")
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
        
        //get pairing key, or set if first launch
      //PersistenceManager.unsetKey() //testing purposes to force a new key without uninstalling
        
       // PhotoDatabaseManager.shared.syncPhotosToDatabase()
        
        
        let userKey = PersistenceManager.retrieveKey()
  
        //only do async code to fetch all keys if userKey isnt created yet
        if userKey == 0 {
            print("user key was 0")
            Task {
                do {
                    let allKeys = try await NetworkManager.shared.retrieveAllKeys()
                    print("all keys array was \(allKeys)")
                    
                    guard !allKeys.isEmpty else {
                        print("No keys returned from database")
                        return
                    }
                    
                    //generate new 8-digit int key not in current keys
                    var newKey: Int
                    repeat {
                        newKey = Int.random(in: 10000000...99999999)
                    } while allKeys.contains(newKey)
                    
                    //save new key to user defaults
                    PersistenceManager.setKey(key: newKey)
                    print("New user key set to : \(newKey)")
                    PersistenceManager.setUser(key: newKey)
                  

                } catch {
                    print("Error retrieeving all keys from database: \(error.localizedDescription)")
                }
            }
        }  else {
            PersistenceManager.setUser(key: userKey)
        }
        
        // Fetch and activate Remote Config on app startup
        RemoteConfigManager.shared.fetchAndActivate { changed, error in
            if let error = error {
                print("Error fetching and activating Remote Config: \(error)")
            } else {
                print("Remote Config fetched and activated on startup.")
            }
        }
        
      
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        
        // Fetch the FCM token once the APNs token is set
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM token: \(error)")
                return
            }
            guard let token = token else {
                print("FCM token not available")
                return
            }
            print("FCM Token: \(token)")
            
            let userKey = PersistenceManager.retrieveKey()
            if userKey != 0 {
                PersistenceManager.subscribeToPairingKey(pairingKey: String(userKey))
            }
            
         
            // Subscribe to a topic after successfully fetching the FCM token
            Messaging.messaging().subscribe(toTopic: "allUsers") { error in
                if let error = error {
                    print("Error subscribing to topic: \(error)")
                } else {
                    print("Subscribed to allUsers topic")
                }
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

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("FCM Token: \(String(describing: fcmToken))")
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    // Handle notifications received in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        self.logToFile(("Notification received in foreground: \(notification.request.content.userInfo)"))
        completionHandler([.banner, .badge, .sound])
    }
    // Handle notification when the app is in background or terminated
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        self.logToFile(("Notification received in background or terminated: \(userInfo)"))
        NotificationCenter.default.post(name: NSNotification.Name("PresentFullScreenPhotoVC"), object: nil, userInfo: userInfo)
        completionHandler()
    }
}
