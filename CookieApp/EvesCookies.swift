//
//  EvesCookies.swift
//  CookieApp
//
//  Created by Peniel Babah on 11/8/24.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import UserNotifications

// Define an AppDelegate class to handle Firebase setup
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Initialize Firebase
        FirebaseApp.configure()
        
        // Request notification permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification authorization: \(error.localizedDescription)")
            }
        }
        
        // Schedule holiday notifications
        NotificationScheduler.scheduleHolidayNotification(
            title: "Happy New Year!",
            body: "Start the year with a special cookie offer!",
            month: 1,
            day: 1
        )
        
        NotificationScheduler.scheduleHolidayNotification(
            title: "Happy Independence Day!",
            body: "Celebrate with our exclusive Independence Day cookie!",
            month: 7,
            day: 4
        )
        
        NotificationScheduler.scheduleHolidayNotification(
            title: "Merry Christmas!",
            body: "Enjoy our festive cookies this holiday season!",
            month: 12,
            day: 25
        )

        // Fetch the user ID from Firebase Authentication
        let userId = Auth.auth().currentUser?.uid ?? "defaultUserId" // Replace "defaultUserId" with a valid fallback if needed
        let userDataManager = UserDataManager()
        
        userDataManager.fetchUserData(userId: userId) { userData in
            if let userData = userData {
                NotificationScheduler.scheduleBirthdayNotification(for: userData)
            } else {
                print("User data not found.")
            }
        }

        return true
    }
}

@main
struct EvesCookies: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authViewModel = AuthViewModel() // Initialize once at the root

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel) // Provide AuthViewModel to the app
        }
    }
}
