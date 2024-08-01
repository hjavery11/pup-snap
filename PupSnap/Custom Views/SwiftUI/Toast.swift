//
//  Toast.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/19/24.
//

import SwiftUI

struct SuccessToast: View {
    private var keyChanged: String = "Succesfully subscribed to new feed."
    
    var body: some View {
        HStack {
            Image(systemName: "checkmark")
            Text(keyChanged)
        }
        .padding(10)
        .background(Color(.systemGreen))
        .cornerRadius(10)
    }
}

struct NoDataToast_Previews: PreviewProvider {
    static var previews: some View {
        SuccessToast()
    }
}
