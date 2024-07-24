//
//  OnboardingView.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/22/24.
//
import SwiftUI

struct OnboardingView: View {
    @Environment(\.presentationMode) private var presentationMode
    
    @StateObject var viewModel = OnboardingVM()

    var body: some View {
        ZStack {
            NavigationStack {
                VStack {
                    HStack{
                        Text("Enter your dog's name:")
                            .font(.custom(MyFonts.base.rawValue, size: 22))
                        Spacer()
                    }
                    .padding()
                    HStack {
                        TextField("Enter Dog Name", text: $viewModel.dogName)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 250)
                            .padding()
                        Image(systemName: viewModel.dogName.isEmpty ? "circle":"checkmark.diamond.fill")
                            .imageScale(.large)
                        Spacer()
                    }
                    HStack{
                        Text("Then choose your dog!")
                        .font(.custom(MyFonts.base.rawValue, size: 22))
                         
                        Spacer()
                    }
                    .padding()
                    
                    ScrollView{
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 30) {
                            ForEach(viewModel.dogPhotos, id: \.self) { dog in
                                Image(dog)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width:100, height: 100)
                                    .border(Color.purple, width: dog == viewModel.selectedDog ? 2:0)
                                    .onTapGesture {
                                        viewModel.selectedDog = dog
                                    }
                            }
                        }
                    }
                    HStack {
                        Spacer()
                        Button {
                            Task {
                                viewModel.isLoading = true
                                try await viewModel.finishOnboarding()
                                PersistenceManager.setupDone()
                                viewModel.isLoading = false
                                presentationMode.wrappedValue.dismiss()
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
                .navigationTitle("Welcome to PupSnap")      
            }
            .foregroundStyle(Color(.systemPurple))
            .opacity(viewModel.isLoading ? 0.1:1)
            
            if viewModel.isLoading {
                ProgressView("Setting up...")
                    .tint(Color(.systemPurple))
                    .controlSize(.large)
            }
            
        }
    }
}

#Preview {
    OnboardingView()
}

