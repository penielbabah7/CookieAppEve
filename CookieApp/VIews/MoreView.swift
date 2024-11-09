//
//  MoreView.swift
//  EvesOriginalSinCookies
//
//  Created by Daniel Baroi on 10/5/24.
//

import SwiftUI

struct MoreView: View {
    @EnvironmentObject var authViewModel: AuthViewModel // Access AuthViewModel from the environment
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("More Options")
                    .font(.largeTitle)
                    .padding()

                // Profile Management
                NavigationLink(destination: ProfileView()) {
                    MoreOptionView(title: "Profile Management", iconName: "person.crop.circle")
                }

                // Order History
                NavigationLink(destination: OrderHistoryView()) {
                    MoreOptionView(title: "Order History", iconName: "clock")
                }

                // Contact Us
                NavigationLink(destination: ContactUsView()) {
                    MoreOptionView(title: "Contact Us", iconName: "phone")
                }

                // About Us
                NavigationLink(destination: AboutUsView()) {
                    MoreOptionView(title: "About Us", iconName: "info.circle")
                }

                // Feedback and Reviews
                NavigationLink(destination: FeedbackView()) {
                    MoreOptionView(title: "Feedback & Reviews", iconName: "star")
                }

                // App Settings
                NavigationLink(destination: AppSettingsView()) {
                    MoreOptionView(title: "App Settings", iconName: "gear")
                }

                // Special Offers
                NavigationLink(destination: SpecialOffersView()) {
                    MoreOptionView(title: "Special Offers", iconName: "tag")
                }

                // Loyalty Program
                NavigationLink(destination: LoyaltyProgramView()) {
                    MoreOptionView(title: "Loyalty Program", iconName: "star.fill")
                }

                // Events and News
                NavigationLink(destination: EventsNewsView()) {
                    MoreOptionView(title: "Events & News", iconName: "calendar")
                }

                // Privacy Policy
                NavigationLink(destination: PrivacyPolicyView()) {
                    MoreOptionView(title: "Privacy Policy", iconName: "shield")
                }

                // Terms of Service
                NavigationLink(destination: TermsOfServiceView()) {
                    MoreOptionView(title: "Terms of Service", iconName: "doc.text")
                }

                // Logout Option
                Button(action: {
                                authViewModel.signOut() // Calls the signOut function from AuthViewModel
                            }) {
                                MoreOptionView(title: "Logout", iconName: "arrow.right.circle")
                                    .foregroundColor(.red)
                            }
                        }
            .padding()
            .background(Color(red: 1.0, green: 1.0, blue: 0.8))
            .ignoresSafeArea()
        }
    }
}
