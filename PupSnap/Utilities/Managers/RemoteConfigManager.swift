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
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        remoteConfig.setDefaults(fromPlist: "remote_config_defaults")       
    }
    
    enum Keys {
        static let maxPhotos = "max_photos"
    }
    
    func fetchAndActivate() async throws {
        try await remoteConfig.fetch()
        try await remoteConfig.activate()
        print("Remote config fetched and activated")
    }
    
    func getValue(forKey key: String) -> String {
        return remoteConfig.configValue(forKey: key).stringValue ?? ""
    }
}
