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
        .alert("Are you sure?", isPresented: $viewModel.showIconConfirmation) {
            Button("Cancel", role: .cancel) { viewModel.newPhoto = "" }
            Button("Yes") { viewModel.updateDogPhoto() }
        } message: {
            Text("Are you sure you want to change the photo for your dog?")
        }
        .alert("Dog Photo Updated", isPresented: $viewModel.showIconSuccess) {
            Button("Ok") {}
        }
    }
}

#Preview {
    DogView(viewModel: SettingsViewModel())
}
