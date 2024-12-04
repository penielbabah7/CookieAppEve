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
struct YourApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var signUpViewModel = SignUpViewModel()

    init() {
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
            } else {
                NavigationView {
                    if signUpViewModel.currentStep > 1 {
                        SignUpFlowView()
                            .environmentObject(authViewModel)
                            .environmentObject(signUpViewModel)
                    } else {
                        SignInView()
                            .environmentObject(authViewModel)
                            .environmentObject(signUpViewModel)
                    }
                }
            }
        }
    }
}
