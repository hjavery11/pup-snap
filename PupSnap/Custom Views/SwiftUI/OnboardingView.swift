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
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case dogName
    }

    init() {
     // Large Navigation Title
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: AppColors.appPurple, 
                                                                .font: UIFont(name: AppFonts.bold.rawValue, size: 35) ?? UIFont.systemFont(ofSize: 35)]
    
   }
    
    var body: some View {
            NavigationStack {
                VStack(spacing:0) {
                    Spacer()
                        .frame(height:92)
                    
                    HStack {
                        Text("Create your pup")
                            .font(Font.custom(AppFonts.medium.rawValue, size: 30))
                            .foregroundColor(Color(.label))
                            .padding(.bottom, 20)
                        Spacer()
                    }
                    
                    HStack{
                        Text("Enter your dog's name")
                            .font(.custom(AppFonts.base.rawValue, size: 14))
                            .opacity(0.65)
                        Spacer()
                    }
                    .padding(.bottom,35)
                    
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(Color.gray, lineWidth: 1)
                        
                        HStack {
                            Image(systemName: "pawprint")
                                .padding(.leading, 28)
                                .frame(width: 17, height: 17)
                            TextField("Dog's name", text: $viewModel.dogName)
                                .padding(EdgeInsets(top: 0, leading: 18, bottom: 0, trailing: 0))
                                .focused($focusedField, equals: .dogName)
                            Spacer()
                        }
                        
                    }
                    .frame(height:52)
                    .padding(.bottom, 35)
                    
                    HStack {
                        Toggle(isOn: $viewModel.termsAgree) {
                            Text("I agree to the Terms and Conditions")
                                .font(.system(size: 14))
                                .foregroundStyle(Color(.label))
                                .opacity(0.7)
                        }
                        .toggleStyle(iOSCheckboxToggleStyle())
                        .tint(Color(.systemPurple))
                        
                        Spacer()
                    }
                    
                    Spacer()
                    
                    HStack(alignment: .center, spacing: 10) {
                        NavigationLink(destination: OnboardingDogView(viewModel: viewModel)) {
                            Text("Next")
                                .bold()
                                .font(.system(size: 16))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                                .frame(width: 345, height: 52)
                                .background(Color(red: 0.56, green: 0.35, blue: 1))
                                .cornerRadius(10)
                        }
                        .disabled(viewModel.dogName.isBlank)
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 40)
                    .padding(.vertical, 19)
                    .frame(width: 345, height: 52, alignment: .center)
                    .background(Color.appPurple)
                    .cornerRadius(10)
                }           
                .navigationTitle("PupSnap")
                .padding([.leading, .trailing], 15)
                Spacer()
                    .frame(height:50)
                   
            }
           
        }
}

#Preview {
    OnboardingView()
}

struct iOSCheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        // 1
        Button(action: {

            // 2
            configuration.isOn.toggle()

        }, label: {
            HStack {
                // 3
                Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")

                configuration.label
            }
        })
    }
}
