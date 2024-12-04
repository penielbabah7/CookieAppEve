//
//  ContentView.swift
//  EvesOriginalSinCookies
//
//  Created by Daniel Baroi on 9/23/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel // Access the authentication state

    var body: some View {
        Group {
            if authViewModel.isLoading {
                // Show the splash screen while loading
                SplashScreenView()
            } else {
                // Show either MenuView or SignInView based on authentication state
                if authViewModel.isSignedIn {
                    MenuView() // Main app view for authenticated users
                } else {
                    SignInView() // Sign-in view for new or returning users who are not signed in
                }
            }
        }
        .onAppear {
            // Trigger the check for authentication state when ContentView appears
            authViewModel.checkAuthState()
        }
    }
}

// Splash Screen Component
import SwiftUI

struct SplashScreenView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var isAnimating = false

    var body: some View {
        ZStack {
            // Background color
            Color(red: 1.0, green: 1.0, blue: 0.8)
                .ignoresSafeArea()

            // Centered logo with animation
            VStack {
                Image("EOSC_LOGO_MATTBLACK_transparent")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300, height: 300)
                    .scaleEffect(isAnimating ? 1.0 : 0.6) // Scale animation
                    .opacity(isAnimating ? 1.0 : 0.0)     // Fade-in animation
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.0)) {
                            isAnimating = true
                        }
                    }

                // Optional loading indicator
                if authViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                        .scaleEffect(1.5)
                        .padding(.top, 20)
                }
            }
        }
        .onAppear {
            // Trigger Firebase auth state check
            authViewModel.checkAuthState()
        }
        .onChange(of: authViewModel.isSignedIn) { isSignedIn in
            if !authViewModel.isLoading && authViewModel.isSignedIn {
                // Handle navigation to the appropriate view (done in `YourApp`).
            }
        }
    }
}
