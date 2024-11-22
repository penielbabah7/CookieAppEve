//
//  NotificationScheduler.swift
//  CookieApp
//
//  Created by Peniel Babah on 11/12/24.
//

import UserNotifications
import Foundation

struct NotificationScheduler {
    static func scheduleBirthdayNotification(for user: UserData) {
        guard let birthdate = user.birthdate else { return } // Ensure birthdate is not nil
        
        let content = UNMutableNotificationContent()
        content.title = "Happy Birthday!"
        content.body = "Celebrate with a free cookie on us!"
        content.sound = .default

        // Extract month and day from user's birthdate
        let calendar = Calendar.current
        let birthdateComponents = calendar.dateComponents([.month, .day], from: birthdate)

        // Set the trigger to fire annually on the user's birthday
        var dateComponents = DateComponents()
        dateComponents.month = birthdateComponents.month
        dateComponents.day = birthdateComponents.day
        dateComponents.hour = 9 // Notification at 9 AM

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "birthdayNotification_\(user.id ?? "")", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling birthday notification: \(error.localizedDescription)")
            }
        }
    }
    
    static func scheduleHolidayNotification(title: String, body: String, month: Int, day: Int) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = 9 // Notification at 9 AM

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "\(title)_Notification", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling \(title) notification: \(error.localizedDescription)")
            }
        }
    }
}
