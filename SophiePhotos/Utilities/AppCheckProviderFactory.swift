//
//  AppCheckProviderFactory.swift
//  SophiePhotos
//
//  Created by Harrison Javery on 7/5/24.
//

import Foundation
import FirebaseCore
import FirebaseAppCheck

class YourSimpleAppCheckProviderFactory: NSObject, AppCheckProviderFactory {
  func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
    return AppAttestProvider(app: app)
  }
}
