//
//  MoreView.swift
//  EvesOriginalSinCookies
//
//  Created by Daniel Baroi on 10/5/24.
//
import SwiftUI
import FirebaseAuth

struct MoreView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // User Profile Summary
                VStack(spacing: 8) {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray)
                    
                    // Display the user's name and loyalty points
                    Text("Welcome, \(authViewModel.userName)")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Loyalty Points: \(authViewModel.loyaltyPoints)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 20)
                
                // More Options Header
                Text("More Options")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 10)
                
                // Grouped Sections
                VStack(alignment: .leading) {
                    
                    // Account Settings Section
                    Section(header: Text("Account Settings").font(.headline).padding(.leading)) {
                        NavigationLink(destination: ProfileView()) {
                            MoreOptionView(title: "Profile Management", iconName: "person.crop.circle")
                        }
                        NavigationLink(destination: OrderHistoryView()) {
                            MoreOptionView(title: "Order History", iconName: "clock")
                        }
                    }
                    
                    // Support Section
                    Section(header: Text("Support").font(.headline).padding(.leading)) {
                        NavigationLink(destination: ContactUsView()) {
                            MoreOptionView(title: "Contact Us", iconName: "phone")
                        }
                        NavigationLink(destination: FeedbackView()) {
                            MoreOptionView(title: "Feedback & Reviews", iconName: "star")
                        }
                        NavigationLink(destination: CateringRequestView()) { // Catering Link
                            MoreOptionView(title: "Request Catering", iconName: "tray.and.arrow.up")
                        }
                    }

                    // App Information Section
                    Section(header: Text("App Information").font(.headline).padding(.leading)) {
                        NavigationLink(destination: AboutUsView()) {
                            MoreOptionView(title: "About Us", iconName: "info.circle")
                        }
                        NavigationLink(destination: AppSettingsView()) {
                            MoreOptionView(title: "App Settings", iconName: "gear")
                        }
                        NavigationLink(destination: FAQView()) {
                            MoreOptionView(title: "FAQ", iconName: "questionmark.circle")
                        }
                        NavigationLink(destination: PrivacyPolicyView()) {
                            MoreOptionView(title: "Privacy Policy", iconName: "shield")
                        }
                        NavigationLink(destination: TermsOfServiceView()) {
                            MoreOptionView(title: "Terms of Service", iconName: "doc.text")
                        }
                    }
                    
                    // Rewards and Offers Section
                    Section(header: Text("Rewards and Offers").font(.headline).padding(.leading)) {
                        NavigationLink(destination: SpecialOffersView()) {
                            MoreOptionView(title: "Special Offers", iconName: "tag")
                        }
                        NavigationLink(destination: LoyaltyProgramView()) {
                            MoreOptionView(title: "Loyalty Program", iconName: "star.fill")
                        }
                        NavigationLink(destination: EventsNewsView()) {
                            MoreOptionView(title: "Events & News", iconName: "calendar")
                        }
                    }
                }
                
                // Logout Option
                Button(action: {
                    authViewModel.signOut()
                }) {
                    MoreOptionView(title: "Logout", iconName: "arrow.right.circle")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .padding(.vertical, 20)
            }
            .padding()
            .background(Color(red: 1.0, green: 1.0, blue: 0.8))
            .ignoresSafeArea()
        }
        .onAppear {
            // Fetch the user's profile when the view appears
            if let userId = authViewModel.auth.currentUser?.uid {
                authViewModel.fetchUserProfile(userId: userId)
            }
        }
    }
}

struct MoreView_Previews: PreviewProvider {
    static var previews: some View {
        MoreView()
            .environmentObject(AuthViewModel()) // Provide a test AuthViewModel for the preview
    }
}
