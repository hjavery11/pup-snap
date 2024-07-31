//
//  OnboardingVM.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/22/24.
//

import UIKit
import FirebaseCrashlytics

class OnboardingVM: ObservableObject {
    
    var dogPhotos: [String] = [
       "australian-shephard-1",
       "australian-shephard-2",
       "beagle-1",
       "chihuahua-black",
       "chihuahua-brown",
       "cream-lab",
       "black-lab-1",
       "french-bulldog-black",
       "french-bulldog-brown",
       "french-bulldog-gray",
       "german-shepherd",
       "golden-retriever-2",
       "golden-retriever",
       "labradoodle",
       "pitbull-brown",
       "pitbull-gray",
       "poodle-brown",
       "poodle-white",
       "rottweiler-1",
       "sophie-iso"
   ]
    
    @Published var dogName: String = ""
    
    @Published var imageName = "circle"
    
    @Published var selectedDog = ""
    
    @Published var isLoading: Bool = false
    
    @Published var termsAgree: Bool = false
    
    var errorMessage = ""
    
    @Published var showAlert: Bool = false
    
    
    func finishOnboarding() async throws {
        let newDog = Dog(photo: selectedDog, name: dogName)
        do {
            try await LaunchManager.shared.finishOnboarding(with: newDog)
        } catch {
            Crashlytics.crashlytics().log("Error during finishOnboarding in OnboardingVM. Error thrown was: \(error)")
            Crashlytics.crashlytics().record(error: error)
            self.errorMessage = "Something went wrong during setup. Please try again. If the issue persists, close and reopen the app.\n Error returned from server was: \(error.localizedDescription)"
            throw error
        }
    }
    
}
