//
//  SettingsView.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/15/24.
//

import SwiftUI

struct SettingsView: View {
    
    @StateObject var viewModel = SettingsViewModel()
    
    init() {
     // Large Navigation Title
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: AppColors.appPurple,
                                                                .font: UIFont(name: AppFonts.bold.rawValue, size: 35) ?? UIFont.systemFont(ofSize: 35)]
    
   }
    
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
                               Toggle("Push Notifications", isOn: $viewModel.pushNotifs)
                                   .onChange(of:viewModel.pushNotifs) { value in
                                       if value {
                                           PersistenceManager.enableNotifications()
                                           print("enabled notifications")
                                       } else {
                                           PersistenceManager.disableNotifications()
                                           print("disabled notifications")
                                       }
                                   }
                           }
                       }
                   } header: {
                       Text("Settings")
                   } footer: {
                       VStack(alignment: .leading) {
                           Text("To share photos with another user, go to \nPairing -> Share")
                           Text("PupSnap (\(viewModel.buildString))")
                               .bold()
                               .padding(.top, 10)
                               .font(.headline)
                       }
                   }
                   
               }
           }
       }
}

#Preview {
    SettingsView()
}

