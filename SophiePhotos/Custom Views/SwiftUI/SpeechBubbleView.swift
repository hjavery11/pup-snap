//
//  SpeechBubbleView.swift
//  SophiePhotos
//
//  Created by Harrison Javery on 7/4/24.
//

import SwiftUI

struct SpeechBubbleView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(text)
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

#Preview {
    SpeechBubbleView(text: "This is a long text message that spans multiple lines to test this")
}
