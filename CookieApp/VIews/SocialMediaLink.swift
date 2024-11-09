//
//  SocialMediaLink.swift
//  CookieApp
//
//  Created by Peniel Babah on 11/8/24.
//

import SwiftUI

struct SocialMediaLink: View {
    let iconName: String
    let url: String

    var body: some View {
        Button(action: {
            if let url = URL(string: url) {
                UIApplication.shared.open(url)
            }
        }) {
            Image(iconName) // Using the image asset
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(-4.0)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)
        }
        .padding(.horizontal)
    }
}
