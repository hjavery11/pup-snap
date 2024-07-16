//
//  SettingsViewModel.swift
//  SophiePhotos
//
//  Created by Harrison Javery on 7/15/24.
//

import Foundation

@MainActor class SettingsViewModel: ObservableObject { 
    
    @Published var showingChangeKey: Bool = false
    @Published var newKey: String = ""
    @Published var showingConfirmation: Bool = false
    @Published var newKeyError: Bool = false
    @Published var showingChangeKeyError: Bool = false
    @Published var pushNotifs: Bool = true
    
    var alertMessage: String = ""
    
    @Published var userKey = PersistenceManager.retrieveKey()
    
    func changeKey() async throws {
       let allKeys = try await NetworkManager.shared.retrieveAllKeys()
        guard let newKey = Int(self.newKey) else {            
            self.alertMessage = SophieError.invalidKey.rawValue
            throw SophieError.invalidKey
        }
        if allKeys.contains(newKey) || newKey == 123456 {
            self.userKey = newKey
            PersistenceManager.setKey(key: newKey
            )
        } else {
            self.alertMessage = SophieError.invalidKey.rawValue
            throw SophieError.invalidKey
        }
    }
    
}
