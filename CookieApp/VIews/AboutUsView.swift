//
//  AboutUsView.swift
//  CookieApp
//
//  Created by Daniel Baroi
//

import SwiftUI
import AVKit

import SwiftUI
import AVKit

struct AboutUsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 20) {
                // Title
                Text("Eve's Original Sin Cookies")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.top)

                // Local Video Player
                VideoPlayer(player: AVPlayer(url: Bundle.main.url(forResource: "EOSC-reel", withExtension: "mov")!))
                    .frame(height: 300)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding(.horizontal)

                // About Us Text
                Text("""
                Two of the most invaluable gifts in life are food and creativity. Eve's Original Sin Cookies combines the two in a way that creates an experience of food creativity for your taste buds to enjoy. Our customers get a delicious cookie created from their desires and ideas, no matter how crazy. Free from the pressures of a perfectionistic society, a person can thrive in their creative food freedom. That's why Eve's Original Sin Cookies stands behind the imperfect, and we do it one cookie at a time. Learn more about how and why we were created in the video above.
                """)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .padding()
            }
            .padding(.horizontal)
        }
    }
}



struct AboutUsView_Previews: PreviewProvider {
    static var previews: some View {
        AboutUsView()
    }
}
