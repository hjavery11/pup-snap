//
//  OnboardingVM.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/22/24.
//

import UIKit

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
    
    
    func finishOnboarding() async throws {
        let newDog = Dog(photo: selectedDog, name: dogName)
        try await LaunchManager.shared.finishOnboarding(with: newDog)
    }
    
}
