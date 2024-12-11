//
//  EvesOriginalSinCookiesApp.swift
//  EvesOriginalSinCookies
//
//  Created by Daniel Baroi on 9/23/24.
//

import SwiftUI
import FirebaseCore
import AVKit
import UIKit
import AVFoundation

@main
struct CookieAppApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var signUpViewModel = SignUpViewModel()

    init() {
        // Configure Firebase
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            if authViewModel.isLoading {
                SplashScreenView()
                    .environmentObject(authViewModel)
                    .environmentObject(signUpViewModel)
            } else if authViewModel.isSignedIn {
                MenuView()
                    .environmentObject(authViewModel)
                    .environmentObject(signUpViewModel)
            } else {
                NavigationView {
                    if signUpViewModel.currentStep > 1 {
                        // Show Sign-Up Flow if the user is in the middle of sign-up
                        SignUpFlowView()
                            .environmentObject(authViewModel)
                            .environmentObject(signUpViewModel)
                    } else {
                        // Default to Sign-In View
                        SignInView()
                            .environmentObject(authViewModel)
                            .environmentObject(signUpViewModel)
                    }
                }
                .navigationViewStyle(StackNavigationViewStyle()) // Optional: Avoid unwanted side effects on iPad
            }
        }
    }
}
