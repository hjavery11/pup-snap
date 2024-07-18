//
//  PairingView.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/15/24.
//

import SwiftUI

struct PairingView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var viewModel: SettingsViewModel
    @FocusState private var keyIsFocused: Bool
    
    var body: some View {
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
                    
                   // ShareLink("Share My Key",item: URL(string: "https://pupsnapapp.com/pair/\(viewModel.userKey)")!, subject: Text("Join me on PupSnap to see all my photos!"))
                    ShareLink("Share My Key",item: URL(string: "https://pupsnapapp.com/pair/56706732")!, subject: Text("Join me on PupSnap to see all my photos!"))
            
                } header: {
                    Text("Pairing")
                } footer: {
                    Text("Share your key with other users to allow them to subscribe to your photos and post photos of their own to the feed.")
                }
            }
            .listStyle(.grouped)
            
        }
        .alert("Something went wrong", isPresented: $viewModel.showingChangeKeyError) {
            Button("Ok") {viewModel.showingChangeKeyError = false}
        } message: {
            Text(viewModel.alertMessage)
        }
        .alert("Are you sure?", isPresented: $viewModel.showingPairingConfirmation) {
            Button("No", role: .cancel) {viewModel.showingChangeKey = true}
            Button("Yes", role: .destructive) {
                Task {
                    do {
                        try await viewModel.changeKey()
                    } catch {
                        viewModel.showingChangeKeyError = true
                    }
                    
                }
                
            }
        } message: {
            let text = viewModel.shareConfirmationMessage ? "Your pairing key will be changed to \(viewModel.newKey) to join the feed that was shared with you. Press cancel if you do not wish to join the shared feed." : "Your new key will be set to: \(viewModel.newKey).\n\nChanging your key will remove access to your current key."
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

#Preview {
    PairingView(viewModel: SettingsViewModel())
}
