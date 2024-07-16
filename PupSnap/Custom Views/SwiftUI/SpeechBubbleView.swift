//
//  SpeechBubbleView.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/4/24.
//

import SwiftUI

struct SpeechBubbleView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var vm: PhotoVC
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(vm.speechBubbleText)
                .padding()
                .background(Color.white)
                .foregroundStyle(.black)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
        }
        .shadow(color: colorScheme == .dark ? Color.white : Color.gray, radius: 9)

    }
}
