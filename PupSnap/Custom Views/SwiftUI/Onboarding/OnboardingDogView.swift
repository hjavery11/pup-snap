//
//  OnboardingDogView.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/31/24.
//

import SwiftUI

struct OnboardingDogView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: OnboardingVM
    @State private var selectedPage = 0
    
    var body: some View {
        ZStack {
            VStack{
                Spacer()
                
                
                let itemsPerPage = 9
                let totalPages = (viewModel.dogPhotos.count + itemsPerPage - 1) / itemsPerPage
                
                TabView(selection: $selectedPage) {
                    ForEach(0..<totalPages, id: \.self) { index in
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100)), GridItem(.adaptive(minimum: 100)), GridItem(.adaptive(minimum: 100))], spacing: 30) {
                            ForEach(viewModel.dogPhotos[index*itemsPerPage..<min((index+1)*itemsPerPage, viewModel.dogPhotos.count)], id: \.self) { dog in
                                Image(dog)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .border(Color.purple, width: dog == viewModel.selectedDog ? 2 : 0)
                                    .onTapGesture {
                                        viewModel.selectedDog = dog
                                    }
                            }
                        }
                        .padding()
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(height: 360)
                .padding(.vertical, 10)
                
                Spacer()
                
                PageIndicator(currentPage: $selectedPage, totalPages: totalPages)
                
                Spacer()
                
                HStack(alignment: .center, spacing: 10) {
                    Button {
                        Task {
                            viewModel.isLoading = true
                            do {
                                try await viewModel.finishOnboarding()
                                PersistenceManager.setupDone()
                                viewModel.isLoading = false                              
                            } catch {
                                viewModel.isLoading = false
                                viewModel.showAlert = true
                            }
                        }
                    } label: {
                        Text("Create Pup")
                            .bold()
                            .font(.system(size: 16))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .frame(width: 345, height: 52)
                            .background(Color.appPurple)
                            .cornerRadius(10)
                    }
                    .disabled(viewModel.selectedDog == "")
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 19)              
            }
            .opacity(viewModel.isLoading ? 0.3:1)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "arrow.left")
                            .tint(Color(.label))
                        Text("Choose your dog")
                            .font(.custom(AppFonts.semibold.rawValue, size: 22))
                            .foregroundStyle(Color(.label))
                            .opacity(viewModel.isLoading ? 0.5:1)
                    }
                }
            }
            if viewModel.isLoading {
                ProgressView("Setting up...")
                    .foregroundStyle(Color(.label))
                    .tint(Color(.systemPurple))
                    .controlSize(.large)
            }
        }
        .disabled(viewModel.isLoading)
        .alert("Something went wrong", isPresented: $viewModel.showAlert) {
            Button("Ok") {viewModel.showAlert = false}
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

#Preview {
    OnboardingDogView(viewModel: OnboardingVM())
}

struct PageIndicator: View {
    @Binding var currentPage: Int
    var totalPages: Int
    
    var body: some View {
        HStack {
            ForEach(0..<totalPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Color.purple : Color.gray)
                    .frame(width: 10, height: 10)
                    .padding(2)
            }
        }
    }
}


