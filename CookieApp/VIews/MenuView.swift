//
//  MenuView.swift
//  EvesOriginalSinCookies
//
//  Created by Daniel Baroi on 9/23/24.
//
//Daniel Baroi added video

import SwiftUI
import AVKit
import AVFoundation

struct MenuView: View {
    @State private var selectedTab = 0
    @State private var cartItems: [String: Int] = [:] // Shared cart state

    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            NavigationView {
                HomeView(selectedTab: $selectedTab, cartItems: $cartItems)
                    .applyBackground()
            }
            .tabItem {
                Image(systemName: "house")
                Text("Home")
            }
            .tag(0)

            // Order Tab
            NavigationView {
                OrderView(cartItems: $cartItems)
                    .applyBackground()
            }
            .tabItem {
                Image(systemName: "list.bullet")
                Text("Order")
            }
            .tag(1)

            // Rewards Tab
            NavigationView {
                RewardsView()
                    .applyBackground()
            }
            .tabItem {
                Image(systemName: "gift")
                Text("Rewards")
            }
            .tag(2)

            // More Tab
            NavigationView {
                MoreView()
                    .applyBackground()
            }
            .tabItem {
                Image(systemName: "ellipsis")
                Text("More")
            }
            .tag(3)
        }
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
            .environmentObject(AuthViewModel())
            .environmentObject(SignUpViewModel())
    }
}

// Background Modifier
extension View {
    func applyBackground() -> some View {
        self.background(Color(red: 1.0, green: 1.0, blue: 0.8).ignoresSafeArea())
    }
}
