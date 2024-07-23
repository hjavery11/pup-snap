//
//  SceneDelegate.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/1/24.
//

import UIKit
import BranchSDK
import Combine
import SwiftUI
import FirebaseStorage

class SceneDelegate: UIResponder, UIWindowSceneDelegate, UITabBarControllerDelegate {
    
    var window: UIWindow?
    var tabBarController: UITabBarController?
    private var cancellables = Set<AnyCancellable>()
    
    var notificationResponse = false
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        print("delegatetest scenedelegate first scene function")
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        print(connectionOptions.userActivities)
        print(connectionOptions.notificationResponse as Any)
 
        
        //  Workaround for SceneDelegate `continueUserActivity` not getting called on cold start:
        if let userActivity = connectionOptions.userActivities.first {
            self.scene(scene, continue: userActivity)          
        }

        
        
        
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        
        let loadingVC = LoadingVC(showText: LaunchManager.shared.firstTimeLaunch)
        window?.rootViewController = loadingVC
        window?.makeKeyAndVisible()
        
        // Trigger setupScene as soon as setupCompletionSubject is completed
        AppDelegate.setupCompletionSubject
            .sink { [weak self] in
                self?.setupScene(connectionOptions: connectionOptions, scene: scene)
            }
            .store(in: &cancellables)
        
        // Trigger setupBranchLink only when branchLinkSubject emits a value
        AppDelegate.branchLinkSubject
            .sink { [weak self] key in
                self?.setupBranchLink(key: key)
            }
            .store(in: &cancellables)
        
        // Trigger handleNotification only when notificationSubject emits a value
        AppDelegate.notificationSubject
            .sink { [weak self] userInfo in
                self?.handleNotification()
            }
            .store(in: &cancellables)
        
        //Trigger branch first time install launch
        AppDelegate.branchFirstTimeLaunch
            .sink { [weak self] key in
                self?.setupBranchFirstLaunch(key)
            }
            .store(in: &cancellables)
        
        AppDelegate.regularFirstTimeLaunch
            .sink { [weak self] key in
                self?.setupFirstTimeLaunch()
            }
            .store(in: &cancellables)
        
    }
    
    private func setupScene(connectionOptions: UIScene.ConnectionOptions, scene: UIScene) {
        print("scene delegate is setting up scene from combine")
        
        tabBarController = createTabbar()
        tabBarController?.delegate = self
        window?.rootViewController = tabBarController
        
        LaunchManager.shared.hasFinishedSceneLaunchSetup = true
        
        //check to see if branch key setup is needed now that scene is ready
        LaunchManager.shared.branchSetup()
        
        //check to see if push notification setup is needed now that scene is ready
        LaunchManager.shared.showPushPhoto()
        
        
    }
    
    private func handleNotification() {
        let userInfo = LaunchManager.shared.pushUserInfo
        print("Handling notification with userInfo: \(userInfo)")
        presentFullScreenPhotoVC(userInfo: userInfo)
    }
    
    private func setupBranchLink(key: Int) {
        print("Attempting to show PairingView with detected pairing key from branch")
        let hostingController = UIHostingController(rootView: PairingView(viewModel: SettingsViewModel(pairingKey: key)))
        hostingController.modalPresentationStyle = .fullScreen
        window?.rootViewController?.present(hostingController, animated: true)
        
    }
    
    private func setupBranchFirstLaunch(_ key: Int) {
        print("attempting to show first time branch install")
        let hostingController = UIHostingController(rootView: PairingView(viewModel: SettingsViewModel(pairingKey: key, firstTimeLaunch: true)))
        hostingController.modalPresentationStyle = .fullScreen
        window?.rootViewController?.present(hostingController, animated: true) {
            //code on dismiss of hosting controller
        }
        LaunchManager.shared.cleanup()
    }
    
    private func setupFirstTimeLaunch() {
        print("attempting to show first time normal install")
        let hostingController = UIHostingController(rootView: OnboardingView())
        hostingController.modalPresentationStyle = .fullScreen
        window?.rootViewController?.present(hostingController, animated: true)
    }
    
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        print("delegatetest scene delegate openURLContexts")
        if let url = URLContexts.first?.url {
            Branch.getInstance().handleDeepLink(url)
        }
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        print("delegatetest scene delegate NSUserAcitvity")
        Branch.getInstance().continue(userActivity)
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
    
    private func presentFullScreenPhotoVC(userInfo: [AnyHashable: Any]) {
        guard let caption = userInfo["caption"] as? String,
              let ratingsString = userInfo["ratings"] as? String,
              let timestampString = userInfo["timestamp"] as? String,
              let id = userInfo["id"] as? String,
              let ratingsData = ratingsString.data(using: .utf8),
              let _ = try? JSONSerialization.jsonObject(with: ratingsData, options: []) as? [String: Int],
              let _ = Int(timestampString) else { return }
        
        let userKey = PersistenceManager.retrieveKey()
        
        let storageRef = Storage.storage().reference().child("images")
        let reference = storageRef.child(String(userKey)).child(id + ".jpg")
        let newImageView = UIImageView()
        
        newImageView.sd_setImage(with: reference, placeholderImage: UIImage(named: "placeholder_image"))
        print("Attempting to send notification to view with image info \(reference.fullPath)")
        let newImageVC = NotificationPhotoVC(imageView: newImageView, caption: caption)
        let navigationController = UINavigationController(rootViewController: newImageVC)
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
        print("delegatetest scene delegate did become active")
        // Access the stored Branch link data
        //Enable tab bar
        
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
    
    func scene(_ scene: UIScene, willContinueUserActivityWithType userActivityType: String) {
        print("delegatetest scene delgate willcontiunueuseractivitywithtype")
        scene.userActivity = NSUserActivity(activityType: userActivityType)
        scene.delegate = self
    }
    
    
}
