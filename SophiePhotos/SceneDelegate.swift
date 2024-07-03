//
//  SceneDelegate.swift
//  SophiePhotos
//
//  Created by Harrison Javery on 7/1/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate, UITabBarControllerDelegate, FullScreenPhotoVCDelegate {
    
    var window: UIWindow?
    var activityIndicator = UIActivityIndicatorView(style: .large)
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        let tabBarController = createTabbar()
        tabBarController.delegate = self
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        configureNavigationBar()
        
        //configure loading spinner
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        if let window = window {
            window.addSubview(activityIndicator)
            NSLayoutConstraint.activate([
                activityIndicator.centerXAnchor.constraint(equalTo: window.centerXAnchor),
                activityIndicator.centerYAnchor.constraint(equalTo: window.centerYAnchor)
            ])
        }
        
        
        // Add observer for the notification
        NotificationCenter.default.addObserver(self, selector: #selector(presentFullScreenPhotoVC(_:)), name: NSNotification.Name("PresentFullScreenPhotoVC"), object: nil)
    }
    
    func createPhotoVC() -> UINavigationController {
        let photoVC = PhotoVC()
        photoVC.title = "📸 Take a Sophie Photo"
        photoVC.tabBarItem = UITabBarItem(title: "Camera", image: UIImage(systemName: "camera"), selectedImage: UIImage(systemName: "camera.fill"))
        
        return UINavigationController(rootViewController: photoVC)
    }
    
    func createFeedVC() -> UINavigationController {
        let feedVC = FeedVC()
        feedVC.title = "🐶 Top Sophie Photos"
        feedVC.tabBarItem = UITabBarItem(title: "Feed", image: UIImage(systemName: "list.bullet.circle"), selectedImage: UIImage(systemName: "list.bullet.circle.fill"))
        
        return UINavigationController(rootViewController: feedVC)
    }
    
    
    
    func createTabbar() -> UITabBarController {
        let tabBar = UITabBarController()
        UITabBar.appearance().tintColor = .systemPurple
        tabBar.viewControllers = [createPhotoVC(),createFeedVC()]
        UITabBar.appearance().backgroundColor = .tertiarySystemFill
        
        
        return tabBar
    }
    
    func configureNavigationBar() {
        UINavigationBar.appearance().tintColor = .systemPurple
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
        guard let userInfo = notification.userInfo, let filePath = userInfo["filePath"] as? String else { return }
        
        //start loading
        activityIndicator.startAnimating()
        
        // Hide the root view controller's view
        if let rootViewController = window?.rootViewController {
            rootViewController.view.isHidden = true
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { // 5 second delay
            NetworkManager.shared.getPhoto(filePath) { [weak self] image in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    // Stop the activity indicator
                    self.activityIndicator.stopAnimating()
                    
                    if let image = image {
                        let photoVC = FullScreenPhotoVC(image: image)
                        photoVC.modalPresentationStyle = .fullScreen
                        photoVC.delegate = self
                        self.window?.rootViewController?.present(photoVC, animated: true, completion: nil)
                    } else {
                        print("Failed to fetch image")
                        // Show the root view controller's view again if the image fetch fails
                        self.window?.rootViewController?.view.isHidden = false
                    }
                }
            }
        }
        
        
    }
    
    func didDismissFullScreenPhotoVC() {
        window?.rootViewController?.view.isHidden = false
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

