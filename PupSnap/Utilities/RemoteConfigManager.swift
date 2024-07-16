//
//  RemoteConfigManager.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/16/24.
//

import Foundation
import FirebaseRemoteConfig

final class RemoteConfigManager {
    
    static let shared = RemoteConfigManager()
    
    private var remoteConfig: RemoteConfig
    
    private init() {
        remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0 // Set to 0 for development, adjust for production
        remoteConfig.configSettings = settings
        remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")
    }
    
    enum Keys {
        static let maxPhotos = "max_photos"
    }
    
    func fetchAndActivate(completion: @escaping (Bool, Error?) -> Void) {
        remoteConfig.fetch { status, error in
            if status == .success {
                print("Config fetched!")
                self.remoteConfig.activate { changed, error in
                    completion(changed, error)
                }
            } else {
                print("Config not fetched")
                print("Error: \(error?.localizedDescription ?? "No error available.")")
                completion(false, error)
            }
        }
    }
    
    func getValue(forKey key: String) -> String {
        return remoteConfig.configValue(forKey: key).stringValue ?? ""
    }
}
