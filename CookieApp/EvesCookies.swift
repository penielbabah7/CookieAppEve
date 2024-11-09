//
//  EvesCookies.swift
//  CookieApp
//
//  Created by Peniel Babah on 11/8/24.
//

import SwiftUI
import FirebaseCore

// Define an AppDelegate class to handle Firebase setup
class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct EvesCookies: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
        @StateObject private var authViewModel = AuthViewModel() // Initialize AuthViewModel

        var body: some Scene {
            WindowGroup {
                ContentView()
                    .environmentObject(authViewModel) // Provide AuthViewModel as an environment object
            }
        }
    }

