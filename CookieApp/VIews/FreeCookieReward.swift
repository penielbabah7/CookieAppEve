//
//  FreeCookieReward.swift
//  CookieApp
//
//  Created by Peniel Babah on 11/11/24.
//

// FreeCookieReward.swift

import Foundation
import UserNotifications // Import UserNotifications to access notification features

class FreeCookieReward {
    private let userDataManager = UserDataManager()

    func checkAndApplyReward(for userId: String) {
        userDataManager.fetchUserData(userId: userId) { userData in
            guard var userData = userData else { return }
            
            // Check if the user qualifies for the free cookie reward
            if userData.purchaseCount >= 12 && !(userData.rewards["freeCookie"] ?? false) {
                // Grant the free cookie reward
                userData.rewards["freeCookie"] = true
                userData.purchaseCount = 0 // Reset the purchase count after applying the reward

                // Save the updated user data to Firestore
                self.userDataManager.saveUserData(userId: userId, userData: userData)

                // Schedule a notification to inform the user
                self.scheduleRewardNotification()
            }
        }
    }

    private func scheduleRewardNotification() {
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Congratulations!"
        content.body = "You've earned a free cookie as a reward for your purchases!"
        content.sound = .default

        // Set the trigger for the notification (1 second delay)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        // Create a notification request
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        // Schedule the notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }
}
