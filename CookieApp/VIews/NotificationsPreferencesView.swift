//
//  NotificationsPreferencesView.swift
//  CookieApp
//
//  Created by Peniel Babah on 11/20/24.
//

import SwiftUI

struct NotificationsPreferencesView: View {
    @State private var marketingEmails = true
    @State private var orderUpdates = true
    @State private var promotions = true

    var body: some View {
        Form {
            Toggle("Marketing Emails", isOn: $marketingEmails)
            Toggle("Order Updates", isOn: $orderUpdates)
            Toggle("Promotions", isOn: $promotions)
        }
        .navigationTitle("Notifications Preferences")
    }
}
