//
//  MainView.swift
//  CookieApp
//
//  Created by Daniel Baroi on 12/8/24.
//

import SwiftUI

struct MainView: View {
    @State private var cartItems: [String: Int] = [:] // Shared cart state
    @State private var selectedTab: Int = 0          // Tracks selected tab (Home or Order)

    var body: some View {
        TabView(selection: $selectedTab) {
            // HomeView
            HomeView(selectedTab: $selectedTab, cartItems: $cartItems)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(0)

            // OrderView
            OrderView(cartItems: $cartItems)
                .tabItem {
                    Label("Order", systemImage: "cart")
                }
                .tag(1)
        }
    }
}
