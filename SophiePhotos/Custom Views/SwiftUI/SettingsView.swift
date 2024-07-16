//
//  SettingsVC.swift
//  SophiePhotos
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
                            NavigationLink("About") {
                                Text("About")
                            }
                        }
                        
                        HStack {
                            NavigationLink("Pairing") {
                                PairingView(viewModel: viewModel)
                            }
                            
                        }
                        HStack {
                            Toggle("Push Notifications", isOn: $viewModel.pushNotifs)
                        }
                    }
                } header: {
                    Text("Settings")
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}

