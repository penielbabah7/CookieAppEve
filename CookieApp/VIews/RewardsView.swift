//
//  RewardsView.swift
//  EvesOriginalSinCookies
//
//  Created by Daniel Baroi on 10/5/24.
//

import SwiftUI
import AVKit
import UIKit
import AVFoundation

struct RewardsView: View {

    var body: some View {

        GeometryReader { geometry in

            ScrollView {

                VStack(spacing: 20) {

                    // Add your content here for Rewards tab (Images, Texts, etc.)

                    Text("Rewards Tab Content")

                        .font(.largeTitle)

                        .padding()

                }

                .padding()

                .padding(.bottom, 100) // Avoid overlap with TabView

                .background(Color(red: 1.0, green: 1.0, blue: 0.8)) // Background color for scrolling content

            }

            .ignoresSafeArea()

            .safeAreaInset(edge: .bottom) {

                Color.clear.frame(height: 50) // Space for TabView

            }

        }

    }

}

