//
//  SceneDelegate.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/1/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate, UITabBarControllerDelegate {
    
    var window: UIWindow?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
//        // Determine who sent the URL.
//        if let urlContext = connectionOptions.urlContexts.first {
//            
//            let sendingAppID = urlContext.options.sourceApplication
//            let url = urlContext.url
//            print("source application = \(sendingAppID ?? "Unknown")")
//            print("url = \(url)")
//            //Process URL
//            guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
//                    let destination = components.path,
//                    let params = components.queryItems else {
//                        print("Invalid URL")
//                        return
//                }
//            
//            if let sharedKey = params.first(where: { $0.name == "key"})?.value {
//                print("Shared key from url: \(sharedKey)")
//            } else {
//                print("No key found in deeplink")
//            }
//        }
        
        
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        let tabBarController = createTabbar()
        tabBarController.delegate = self
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        // Add observer for the notification
        NotificationCenter.default.addObserver(self, selector: #selector(presentFullScreenPhotoVC(_:)), name: NSNotification.Name("PresentFullScreenPhotoVC"), object: nil)
    }
    
    func createPhotoVC() -> UINavigationController {
        let photoVC = PhotoVC()
        photoVC.title = "📸 PupSnap"
        photoVC.tabBarItem = UITabBarItem(title: "Camera", image: UIImage(systemName: "camera"), selectedImage: UIImage(systemName: "camera.fill"))
        let navController = UINavigationController(rootViewController: photoVC)
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.systemPurple]
        navController.navigationBar.titleTextAttributes = textAttributes
        navController.navigationBar.prefersLargeTitles = true
        
        return navController
    }
    
    func createFeedVC() -> UINavigationController {
        let feedVC = FeedVC()
        let navController = UINavigationController(rootViewController: feedVC)
        feedVC.tabBarItem = UITabBarItem(title: "Feed", image: UIImage(systemName: "list.bullet.circle"), selectedImage: UIImage(systemName: "list.bullet.circle.fill"))
        
        return navController
    }
    
    func createSettingsVC() -> UINavigationController {
        let settingsVC = SettingsVC()
        let navController = UINavigationController(rootViewController: settingsVC)
        settingsVC.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "ellipsis.rectangle"), selectedImage: UIImage(systemName: "ellipsis.rectangle.fill"))
        
        return navController
    }
    
    func createTabbar() -> UITabBarController {
        let tabBar = UITabBarController()
        UITabBar.appearance().tintColor = .systemPurple
        tabBar.viewControllers = [createPhotoVC(), createFeedVC(),createSettingsVC()]
        UITabBar.appearance().backgroundColor = .tertiarySystemFill
        
        return tabBar
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let navController = viewController as? UINavigationController, let topVC = navController.topViewController {
            if let photoVC = topVC as? PhotoVC {
                photoVC.tabSelected() // call func inside VC
            } else if let feedVC = topVC as? FeedVC {
                feedVC.tabSelected()
            }
        }
    }
    
    @objc func presentFullScreenPhotoVC(_ notification: Notification) {
        //    id: photoId,
        //                caption: photoData.caption || '',
        //                path: photoData.path || '',
        //                ratings: JSON.stringify(photoData.ratings || {}),
        //                timestamp: String(photoData.timestamp || '')
        
        print(notification)
        
        guard let userInfo = notification.userInfo else { return }
        guard let filePath = userInfo["path"] as? String,
              let caption = userInfo["caption"] as? String,
              let ratingsString = userInfo["ratings"] as? String,
              let timestampString = userInfo["timestamp"] as? String,
              let id = userInfo["id"] as? String,
              let ratingsData = ratingsString.data(using: .utf8),
              let ratings = try? JSONSerialization.jsonObject(with: ratingsData, options: []) as? [String: Int],
              let timestamp = Int(timestampString) else { return }
        
        let photo = Photo(caption: caption, ratings: ratings, timestamp: timestamp, path: filePath, image: nil, id: id)
        let fullScreenVC = FullScreenPhotoVC(photo: photo, indexPath: nil)
        
        let navigationController = UINavigationController(rootViewController: fullScreenVC)
        window?.rootViewController?.present(navigationController, animated: true, completion: nil)
    }
    
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
}
