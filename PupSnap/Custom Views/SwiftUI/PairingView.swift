//
//  PairingView.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/15/24.
//

import SwiftUI

struct PairingView: View {
    @Environment(\.presentationMode) private var presentationMode
    
    @ObservedObject var viewModel: SettingsViewModel
    @FocusState private var keyIsFocused: Bool
    
    var body: some View {
        ZStack{
            NavigationStack {
                List {
                    Section {
                        HStack {
                            Text("My Key")
                                .font(.title3)
                            Spacer()
                            Text(String(viewModel.userKey))
                                .font(.title3)
                        }
                        
                        HStack {
                            Spacer()
                            Text("Change Key")
                                .font(.footnote)
                                .onTapGesture {
                                    viewModel.showingChangeKey = true
                                }
                        }
                        
                        ShareLink(item: URL(string: LaunchManager.shared.shareURL ?? "https://pupsnapapp.com")!, subject: Text("Join me on PupSnap!"))
                        
                    } header: {
                        Text("Pairing")
                    } footer: {
                        Text("Share your key with other users to allow them to subscribe to your photos and post photos of their own to the feed.")
                    }
                }
                .listStyle(.grouped)
                
            }
            if viewModel.isLoading {
                ProgressView("Applying...")                
                    .tint(Color(.systemPurple))
            }
        }
        .onAppear {
            viewModel.userKey = PersistenceManager.retrieveKey()
        }
        .alert("Pairing", isPresented: $viewModel.comingFromBranchLink) {
            Button("Ok", role: .none) {
                Task { @MainActor in
                    do {
                        viewModel.isLoading = true
                        try await viewModel.changeKey()
                        try await viewModel.updateDog()
                        viewModel.isLoading = false
                        LaunchManager.shared.showToast = true
                        LaunchManager.shared.launchingFromBranchLink = false
                        presentationMode.wrappedValue.dismiss()
                        viewModel.comingFromBranchLink = false
                    } catch {
                        viewModel.isLoading = false
                        viewModel.showingChangeKeyError = true
                    }
                    
                }
                
            }
        } message: {
            let text = "Your pairing key will be changed to \(viewModel.newKey) to join the feed that was shared with you."
            Text(text)
          
        }
        .alert("PupSnap", isPresented: $viewModel.firstTimeLaunch) {
            Button("Ok", role: .none) {
                Task {
                    do {
                        viewModel.isLoading = true
                        try await viewModel.subscribeToBranchKey()
                        try await LaunchManager.shared.refreshToken()
                        try await viewModel.updateDog()
                        viewModel.isLoading = false
                        LaunchManager.shared.showToast = true
                        presentationMode.wrappedValue.dismiss()                     
                        AppDelegate.setupCompletionSubject.send(())                     
                        PersistenceManager.setupDone()
                        viewModel.firstTimeLaunch = false
                    } catch {
                        viewModel.isLoading = false
                        viewModel.showingChangeKeyError = true
                    }
                    
                }
                
            }
        } message: {
            let text = "You are joining the feed of the person who shared this app with you."
            Text(text)
          
        }
        .alert("Something went wrong", isPresented: $viewModel.showingChangeKeyError) {
            Button("Ok") {viewModel.showingChangeKeyError = false}
        } message: {
            Text(viewModel.alertMessage)
        }
        .alert("Are you sure?", isPresented: $viewModel.showingPairingConfirmation) {
            Button("Cancel", role: .cancel) {viewModel.showingChangeKey = true}
            Button("Yes", role: .destructive) {
                Task {
                    do {
                        viewModel.isLoading = true
                        try await viewModel.changeKey()
                        viewModel.isLoading = false                        
                    } catch {
                        viewModel.isLoading = false
                        viewModel.showingChangeKeyError = true
                    }
                    
                }
                
            }
        } message: {
            let text = "Your new key will be set to: \(viewModel.newKey).\n\nChanging your key will remove access to your current key."
            Text(text)
          
        }      
        
        .sheet(isPresented: $viewModel.showingChangeKey) {
            VStack {
                Text("Change Key")
                TextField("New key", text: $viewModel.newKey)
                    .frame(height: 40)
                    .keyboardType(.numberPad)
                    .padding(.leading, 5)
                    .border(viewModel.newKeyError ? Color(.systemRed) : Color(.secondaryLabel), width: 0.5)
                    .background(Color(.tertiarySystemFill))
                    .focused($keyIsFocused)
                  
                
                Button {
                    if viewModel.newKey != "" {
                        keyIsFocused = false
                        viewModel.showingChangeKey = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            viewModel.showingPairingConfirmation = true
                        }
                      
                    } else {
                        viewModel.newKeyError = true
                    }
                } label: {
                    Text("Submit")
                }
                .frame(width: 75, height: 40)
                .background(Color(.systemRed))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding()
            .presentationDetents([.height(150)])
            .presentationDragIndicator(.visible)
        }
    
    
    }
  
}
