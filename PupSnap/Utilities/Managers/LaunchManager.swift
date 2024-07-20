//
//  LaunchManager.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/19/24.
//

import UIKit

class LaunchManager {
    
    static let shared = LaunchManager()
    
    var hasFinishedUserLaunchSetup: Bool = false
    var hasFinishedSceneLaunchSetup: Bool = false
    var launchingFromBranchLink: Bool = false
    var launchingFromPushNotification: Bool = false
    
    var showToast: Bool = false
    
    var sharedPairingKey: Int?
    
    private init() {}
    
    func branchSetup() {
        guard let sharedPairingKey = self.sharedPairingKey else { return }
        if hasFinishedUserLaunchSetup && launchingFromBranchLink && hasFinishedSceneLaunchSetup{
            AppDelegate.branchLinkSubject.send(sharedPairingKey)          
        }
    }
    
    func branchFirstTimeLaunch(_ key: Int) {
        AppDelegate.branchFirstTimeLaunch.send(key)
    }    
    
    
}
