//
//  ContentView.swift
//  EvesOriginalSinCookies
//
//  Created by Daniel Baroi on 9/23/24.
//

import SwiftUI

struct ContentView: View {
    @State private var isActive = false // Controls the splash screen display
    @EnvironmentObject var authViewModel: AuthViewModel // Access the authentication state

    var body: some View {
        if isActive {
            // After splash screen, show either MenuView (if signed in) or SignInView
            if authViewModel.isSignedIn {
                MenuView() // Main app view for authenticated users
            } else {
                SignInView() // Sign-in view for new or returning users who are not signed in
            }
        } else {
            // Splash Screen
            ZStack {
                // Background color
                Color(red: 1.0, green: 1.0, blue: 0.8)
                    .ignoresSafeArea()
                
                // App logo or splash image
                Image("EOSC_LOGO_MATTBLACK_transparent")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 700, height: 600)
            }
            .onAppear {
                // Set a delay to transition from the splash screen
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    withAnimation {
                        isActive = true
                    }
                }
            }
        }
    }
}

