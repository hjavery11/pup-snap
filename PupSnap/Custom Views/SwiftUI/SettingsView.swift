//
//  SettingsView.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/15/24.
//

import SwiftUI

struct SettingsView: View {
    
    @StateObject var viewModel = SettingsViewModel()
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    List {
                        HStack {
                            NavigationLink("Pairing") {
                                PairingView(viewModel: viewModel)
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
    }
}

#Preview {
    SettingsView()
}

