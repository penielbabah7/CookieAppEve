//
//  MenuView.swift
//  EvesOriginalSinCookies
//
//  Created by Daniel Baroi on 9/23/24.
//
import SwiftUI
import AVKit
import AVFoundation

struct MenuView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            
            // Home Tab
            NavigationView {
                HomeView(selectedTab: $selectedTab)
                    .background(Color(red: 1.0, green: 1.0, blue: 0.8))
            }
            .tabItem {
                Image(systemName: "house")
                Text("Home")
            }
            .tag(0)

            // Order Tab
            NavigationView {
                OrderView()
                    .background(Color(red: 1.0, green: 1.0, blue: 0.8))
            }
            .tabItem {
                Image(systemName: "list.bullet")
                Text("Order")
            }
            .tag(1)
            
            // Rewards Tab
            NavigationView {
                RewardsView()
                    .background(Color(red: 1.0, green: 1.0, blue: 0.8))
            }
            .tabItem {
                Image(systemName: "gift")
                Text("Rewards")
            }
            .tag(2)

            // More Tab
            NavigationView {
                MoreView()
                    .background(Color(red: 1.0, green: 1.0, blue: 0.8))
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
            .environmentObject(AuthViewModel()) // Inject a test instance of AuthViewModel
    }
}
