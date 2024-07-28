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
import SDWebImage

class SceneDelegate: UIResponder, UIWindowSceneDelegate, UITabBarControllerDelegate {
    
    var window: UIWindow?
    var tabBarController: UITabBarController?
    private var cancellables = Set<AnyCancellable>()
    
    var notificationResponse = false
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        print("scene first call")
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        //  Workaround for SceneDelegate `continueUserActivity` not getting called on cold start:
        if let userActivity = connectionOptions.userActivities.first {
            self.scene(scene, continue: userActivity)          
        }
        
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        
       let loadingVC = LoadingVC()
        window?.rootViewController = loadingVC
        window?.makeKeyAndVisible()
        print("loading vc shown")
        
        // Trigger setupScene as soon as setupCompletionSubject is completed
        AppDelegate.standardSceneSetup
            .sink { [weak self] in
                self?.setupScene(connectionOptions: connectionOptions, scene: scene)
            }
            .store(in: &cancellables)
        
        // Trigger setupBranchLink only when branchLinkSubject emits a value
        AppDelegate.branchDeepLinkEvent
            .sink { [weak self] key in
                self?.showPairingViewForBranchDeepLink(key: key)
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
                print("did branchFirstTimeLaunch sink")
            }
            .store(in: &cancellables)
        
        AppDelegate.regularFirstTimeLaunch
            .sink { [weak self] key in
                self?.setupFirstTimeLaunch()
            }
            .store(in: &cancellables)
        
        AppDelegate.branchPasteboardEvent
            .sink { [weak self] key in
                self?.setupBranchPasteboard()
            }
            .store(in: &cancellables)
        
        LaunchManager.shared.determineLaunch()
        
        print("end of scene first function")
    }
    
    private func setupBranchPasteboard() {
        let pasteVC = PasteModalVC()
        let nav = UINavigationController(rootViewController: pasteVC)
        
        window?.rootViewController = nav
        print("presented paste vc")
    }
          
    private func setupScene(connectionOptions: UIScene.ConnectionOptions, scene: UIScene) {
        
        Task { @MainActor in
            print("setup tabcontroller base scene")
            if LaunchManager.shared.launchType == .standardReturningLaunch {
                try await LaunchManager.shared.runStandardSetup()
            }
            tabBarController = createTabbar()
            tabBarController?.delegate = self
            window?.rootViewController = tabBarController

            if LaunchManager.shared.openFromPush {
                handleNotification()
            }
        }
       
        //create share link so its ready
        LaunchManager.shared.createBranchLink()
        
    }
    
    private func handleNotification() {
        let userInfo = LaunchManager.shared.pushUserInfo
        
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
        
        newImageView.sd_imageIndicator = SDWebImageProgressIndicator.bar
        newImageView.sd_setImage(with: reference, placeholderImage: UIImage(named: "placeholder_image"))
        let newImageVC = NotificationPhotoVC(imageView: newImageView, caption: caption)
        
        window?.rootViewController?.present(newImageVC, animated: true, completion: nil)
        LaunchManager.shared.openFromPush = false
    }
    
    private func showPairingViewForBranchDeepLink(key: Int) {
        let hostingController = UIHostingController(rootView: PairingView(viewModel: SettingsViewModel(pairingKey: key)))
        hostingController.modalPresentationStyle = .fullScreen
        
        window?.rootViewController = hostingController
        
    }
    
    private func setupBranchFirstLaunch(_ key: Int) {
        let hostingController = UIHostingController(rootView: PairingView(viewModel: SettingsViewModel(pairingKey: key)))
        hostingController.modalPresentationStyle = .fullScreen
        
        window?.rootViewController?.present(hostingController, animated: true) {
          
        }
    }
    
    private func setupFirstTimeLaunch() {
        let hostingController = UIHostingController(rootView: OnboardingView())
        hostingController.modalPresentationStyle = .fullScreen
        
        let appear = UINavigationBarAppearance()

            let atters: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.systemPurple
            ]

            appear.largeTitleTextAttributes = atters
            appear.titleTextAttributes = atters
        
        UINavigationBar.appearance().standardAppearance = appear
        
        
        window?.rootViewController = hostingController
    }
    
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            Branch.getInstance().handleDeepLink(url)
        }
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
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
        settingsVC.title = "Settings"
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
  
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        // Access the stored Branch link data
       print("scenedidbecomeactive")
        print(LaunchManager.shared.launchType ?? "no launch type")
        
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.

        if LaunchManager.shared.openFromPush {
            handleNotification()
        }
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
    }
    
    func scene(_ scene: UIScene, willContinueUserActivityWithType userActivityType: String) {
        scene.userActivity = NSUserActivity(activityType: userActivityType)
        scene.delegate = self
    }
    
    
}
