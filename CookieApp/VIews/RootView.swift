//
//  RootView.swift
//  CookieApp
//
//  Created by Peniel Babah on 11/22/24.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        Group {
            if authViewModel.isLoading {
                // Show a loading indicator while checking user state
                ProgressView("Loading...")
            } else if authViewModel.isSignedIn {
                // If the user is signed in, show the main profile or app interface
                ProfileView()
            } else {
                // If the user is not signed in, show the sign-in page
                SignInView()
            }
        }
        .onAppear {
            // Check the user's state when the view appears
            authViewModel.checkAuthState()
        }
    }
}
