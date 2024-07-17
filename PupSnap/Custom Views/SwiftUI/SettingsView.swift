//
//  SettingsView.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/15/24.
//

import SwiftUI

struct SettingsView: View {
    
    @StateObject var viewModel = SettingsViewModel()
    var pairingKey: String?
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    List {
                        HStack {
                            NavigationLink("Pairing") {
                                PairingView(viewModel: viewModel, pairingKey: pairingKey)
                            }
                            
                        }
                       
                        HStack {
                            NavigationLink("Customize Dog") {
                                DogView(viewModel: viewModel)
                            }
                        }
                        
                        HStack {
                            NavigationLink("About") {
                                Text("About")
                            }
                        }
                       
                        HStack {
                            Toggle("Push Notifications", isOn: $viewModel.pushNotifs)
                        }
                    }
                } header: {
                    Text("Settings")
                } footer: {
                    Text("To share photos with another user, go to Pairing -> Share My Key")
                }
               
            }
        }
        .onAppear {
            if pairingKey != nil {
                DispatchQueue.main.async {
                    // Navigate to PairingView if pairingKey is provided
                    let pairingView = PairingView(viewModel: viewModel, pairingKey: pairingKey)
                    let hostingController = UIHostingController(rootView: pairingView)
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
                        window.rootViewController?.present(hostingController, animated: true, completion: nil)
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}

