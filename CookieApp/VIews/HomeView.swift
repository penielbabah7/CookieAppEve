//
//  HomeView.swift
//  EvesOriginalSinCookies
//
//  Created by Daniel Baroi on 10/5/24.
//

import SwiftUI
import AVKit
import UIKit
import AVFoundation

struct HomeView: View {
    @Binding var selectedTab: Int
    @Binding var cartItems: [String: Int] // Shared cart state
    @State private var boxHeight: CGFloat = 0.75
    @State private var player: AVPlayer = {
        // Initialize the AVPlayer with looping functionality
        let url = Bundle.main.url(forResource: "EOSC Reel", withExtension: "mp4")!
        let player = AVPlayer(url: url)
        player.isMuted = false
        player.actionAtItemEnd = .none
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
            player.seek(to: .zero)
            player.play()
        }
        return player
    }()
    @State private var showAddToCartPrompt = false
    @State private var selectedCookie: String?

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 20) {
                    // Video Player
                    VideoPlayer(player: player)
                        //.resizable()
                        .ignoresSafeArea()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                        
                        .frame(width: geometry.size.width, height: geometry.size.height * boxHeight)
                        .aspectRatio(contentMode: .fill)
                        .clipped()
                        .padding(.horizontal, -20)
                        //.padding(.horizontal,20)
                        .padding(.vertical, -30)
                        .onAppear {
                            if let videoURL = Bundle.main.url(forResource: "EOSC Reel", withExtension: "mp4") {
                                player = AVPlayer(url: videoURL)
                                player.play()
                            }
                        }
                        //.animation(.easeInOut, value: boxHeight)

                    // Cookies of the Month
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Cookies of the Month")
                            .font(.system(size: 35, weight: .bold))
                            .padding(.horizontal, -5)
                            .padding(.vertical, 10)

                        ForEach(["Strawberry", "Confetti"], id: \.self) { cookieName in
                            Button(action: {
                                selectedCookie = cookieName
                                showAddToCartPrompt = true
                            }) {
                                VStack(alignment: .leading) {
                                    Text(cookieName)
                                        .font(.system(size: 25, weight: .bold))
                                    Text("Cookie")
                                        .font(.system(size: 25, weight: .bold))
                                }
                                .foregroundColor(.black)
                                .padding(.horizontal)
                            }
                            .alert(isPresented: $showAddToCartPrompt) {
                                Alert(
                                    title: Text("Add \(selectedCookie ?? "") to Cart?"),
                                    message: Text("Would you like to add this cookie to your cart?"),
                                    primaryButton: .default(Text("Yes")) {
                                        if let cookie = selectedCookie {
                                            cartItems[cookie, default: 0] += 1
                                        }
                                    },
                                    secondaryButton: .cancel()
                                )
                            }
                        }

                        // View Cart Button
                        NavigationLink(destination: CartView(cartItems: $cartItems)) {
                            Text("View Cart")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.top, 20)
                }
                .padding()
                .padding(.bottom, 100)
                .background(Color(red: 1.0, green: 1.0, blue: 0.8))
            }
            .background(Color(red: 1.0, green: 1.0, blue: 0.8))
            .ignoresSafeArea()
        }
    }
}
