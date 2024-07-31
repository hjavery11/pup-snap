//
//  OnboardingDogView.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/31/24.
//

import SwiftUI

struct OnboardingDogView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: OnboardingVM
    
    var body: some View {
            VStack{
//                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 30) {
//                    ForEach(viewModel.dogPhotos, id: \.self) { dog in
//                        Image(dog)
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width:100, height: 100)
//                            .border(Color.purple, width: dog == viewModel.selectedDog ? 2:0)
//                            .onTapGesture {
//                                viewModel.selectedDog = dog
//                            }
//                    }
//                }
                HStack {
                    Spacer()
                    Button {
                        Task {
                            viewModel.isLoading = true
                            try await viewModel.finishOnboarding()
                            PersistenceManager.setupDone()
                            viewModel.isLoading = false
                        }
                    } label: {
                        Text("Get Started")
                        Image(systemName: "arrow.right")
                        
                    }
                    .bold()
                    .tint(Color(.systemPurple))
                    .padding(.trailing, 25)
                    .buttonStyle(BorderedProminentButtonStyle())
                    .foregroundStyle(Color(.white))
                    .disabled(viewModel.dogName.isEmpty || viewModel.selectedDog == "")
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Back", systemImage: "arrow.left.circle")
                    }
                }
            }
    }
}

#Preview {
    OnboardingDogView(viewModel: OnboardingVM())
}

//if viewModel.isLoading {
//    ProgressView("Setting up...")
//        .tint(Color(.systemPurple))
//        .controlSize(.large)
//}
