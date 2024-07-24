//
//  DogView.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/16/24.
//

import SwiftUI

struct DogView: View {
    
    @ObservedObject var viewModel: SettingsViewModel
    
    
    var body: some View {
        VStack {
            HStack {
                Text("Dog name")
                    .font(.title2)
                TextField("Enter name", text:$viewModel.newDogName)
                    .onSubmit {
                        if viewModel.newDogName != viewModel.dogName && viewModel.newDogName != ""{
                            viewModel.showNameConfirmation = true
                        }
                    }
                    .keyboardShortcut(.defaultAction)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Button("Cancel") {
                                UIApplication.shared.endEditing()
                                viewModel.newDogName = viewModel.dogName
                            }
                            Spacer()
                            Button("Clear") {
                                viewModel.newDogName = ""
                            }
                        }
                    }
            }
            .padding()
            
        ScrollView{
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 30) {
                ForEach(viewModel.dogPhotos, id: \.self) { dog in
                    if dog != viewModel.selectedPhoto {
                        Image(dog)
                            .resizable()
                            .scaledToFit()
                            .frame(width:100, height: 100)
                            .onTapGesture {
                                viewModel.newPhoto = dog
                                viewModel.showIconConfirmation = true
                            }
                    }
                }
            }
        }
    }
        .alert("Are you sure?", isPresented: $viewModel.showIconConfirmation) {
            Button("Cancel", role: .cancel) { viewModel.newPhoto = "" }
            Button("Yes") { 
                Task {
                    await viewModel.updateDogPhoto()
                }
            }
        } message: {
            Text("Are you sure you want to change the photo for your dog?")
        }
        .alert("Dog Photo Updated", isPresented: $viewModel.showPhotoChangeSuccess) {
            Button("Ok") {}
        }
        .alert("Dog name has been updated", isPresented: $viewModel.dogNameSuccess) {
            Button("Ok") {}
        }
        .alert("Are you sure?", isPresented: $viewModel.showNameConfirmation) {
            Button("Cancel", role: .cancel) { viewModel.newDogName = "" }
            Button("Yes") {
                Task {
                    await viewModel.updateDogName()
                }
            }
        } message: {
            Text("Are you sure you want to change the name of your dog to \(viewModel.newDogName)?")
        }
    }
}

#Preview {
    DogView(viewModel: SettingsViewModel())
}
