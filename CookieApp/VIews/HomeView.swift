//
//  HomeView.swift
//  EvesOriginalSinCookies
//
//  Created by Daniel Baroi on 10/5/24.
//

// Hello my name is Daniel B

import SwiftUI
import AVKit
import UIKit
import AVFoundation

struct HomeView: View {
    @Binding var selectedTab: Int
    @State private var boxHeight: CGFloat = 0.75
    @State private var player = AVPlayer()
    @State private var showNutritionalInfo = false
    @State private var selectedCookie: String?

    

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 20) {
                    // Video Player (unchanged)
                    VideoPlayer(player: player)
                        .frame(height: geometry.size.height * boxHeight)
                        .padding(.horizontal, -20)
                        .padding(.vertical, -30)
                        .onAppear {
                            if let videoURL = Bundle.main.url(forResource: "EOSC Reel", withExtension: "mp4") {
                                player = AVPlayer(url: videoURL)
                                player.play()
                              
                            }
                        }
                        .animation(.easeInOut, value: boxHeight)

                    // Cookie of the Month Section
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Cookies of the Month")
                            .font(.system(size: 35, weight: .bold))
                            .padding(.horizontal, -5)
                            .padding(.vertical, 10)

                        CookieButton(cookieName: "Strawberry")
                        CookieButton(cookieName: "Confetti")

                        // Order Now Button
                        Button(action: {
                            selectedTab = 1 // Switch to Order Tab
                        }) {
                            Text("Order Now")
                                .font(.system(size: 20, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 20)
                }
                .padding()
                .padding(.bottom, 100)
                .background(Color(red: 1.0, green: 1.0, blue: 0.8))
            }
            .background(Color(red: 1.0, green: 1.0, blue: 0.8))
            .ignoresSafeArea()
            .sheet(isPresented: $showNutritionalInfo) {
                NutritionalInfoView(cookieName: selectedCookie ?? "")
            }
        }
    }
    
    private func CookieButton(cookieName: String) -> some View {
        VStack(alignment: .leading) {
            Button(action: {
                selectedTab = 1 // Switch to Order Tab
            }) {
                Text(cookieName)
                    .font(.system(size: 25, weight: .bold))
                Text("Cookie")
                    .font(.system(size: 25, weight: .bold))
            }
            .foregroundColor(.black)
            
            Button(action: {
                selectedCookie = cookieName
                showNutritionalInfo = true
            }) {
                Text("Learn More")
                    .font(.system(size: 15))
                    .foregroundColor(.blue)
            }
            .padding(.top, 5)
        }
        .padding(.horizontal)
    }
}
struct NutritionalInfoView: View {
    let cookieName: String
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack {
                Text("Nutritional Information for \(cookieName) Cookie")
                    .font(.headline)
                    .padding()
                
                // Add your nutritional information here
                Text("Calories: 250")
                Text("Fat: 12g")
                Text("Carbs: 33g")
                Text("Protein: 3g")
                
                Spacer()
            }
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}




