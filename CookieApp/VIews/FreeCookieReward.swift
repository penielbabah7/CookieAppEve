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
            if userData.purchaseCount >= 12 && !(userData.rewards["freeCookie"] ?? false) {
                // Grant the free cookie reward
                userData.rewards["freeCookie"] = true
                userData.purchaseCount = 0 // Reset purchase count after reward

                self.userDataManager.saveUserData(userId: userId, userData: userData)

                // Schedule a notification
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                NotificationManager.shared.scheduleNotification(
                    title: "Congratulations!",
                    body: "You've earned a free cookie!",
                    trigger: trigger
                )
            }
        }
    }
}
