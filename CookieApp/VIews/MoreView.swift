//
//  MoreView.swift
//  EvesOriginalSinCookies
//
//  Created by Daniel Baroi on 10/5/24.
//

import SwiftUI
import AVKit
import UIKit
import AVFoundation


struct MoreView: View {
    @State private var player: AVPlayer?

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 20) {
                    // Add your content here for More tab (Images, Texts, etc.)
                    Text("More Tab Content")
                        .font(.largeTitle)
                        .padding()

                    // Video Player Section
                    if let player = player {
                        VideoPlayer(player: player)
                            .frame(height: geometry.size.height * 0.4) // Adjust height as needed
                            .onAppear {
                                player.play() // Start playing the video when it appears
                            }
                    } else {
                        Text("Video not available")
                    }
                }
                .padding()
                .padding(.bottom, 100) // Avoid overlap with TabView
                .background(Color(red: 1.0, green: 1.0, blue: 0.8)) // Background color for scrolling content
                .onAppear {
                    setupVideoPlayer()
                }
            }
            .ignoresSafeArea()
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 50) // Space for TabView
            }
        }
    }

    private func setupVideoPlayer() {
        if let videoPath = Bundle.main.path(forResource: "EOSC-reel", ofType: "mp4") {
            let videoURL = URL(fileURLWithPath: videoPath)
            player = AVPlayer(url: videoURL)
        } else {
            print("Video file not found.")
        }
    }
}

