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
                // User Profile Summary Section
                VStack(spacing: 12) {
                    // Circular avatar with shadow
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.blue]),
                                startPoint: .top,
                                endPoint: .bottom
                            ))
                            .frame(width: 100, height: 100)
                            .shadow(color: Color.blue.opacity(0.2), radius: 10, x: 0, y: 5)
                        
                        if let profileImageURL = authViewModel.profilePictureURL,
                           let url = URL(string: profileImageURL) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                            } placeholder: {
                                ProgressView()
                                    .frame(width: 80, height: 80)
                            }
                        } else {
                            Image(systemName: "person.fill")
                                .resizable()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.white)
                        }
                    }

                    // Welcome message and loyalty points
                    Text("Welcome, \(authViewModel.userName)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    Text("Loyalty Points: \(authViewModel.loyaltyPoints)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)
                .padding(.bottom, 20)

                // Existing VStack for Essential Options
                VStack(alignment: .leading, spacing: 30) {
                    SectionView(title: "My Account", options: [
                        NavigationOption(title: "Profile Management", iconName: "person.crop.circle", destination: ProfileView()),
                        NavigationOption(title: "Order History", iconName: "clock", destination: OrderHistoryView())
                    ])

                    SectionView(title: "Support & Info", options: [
                        NavigationOption(title: "Contact Us", iconName: "phone", destination: ContactUsView()),
                        NavigationOption(title: "About Us", iconName: "info.circle", destination: AboutUsView())
                    ])

                    SectionView(title: "Rewards & Offers", options: [
                        NavigationOption(title: "Special Offers", iconName: "tag", destination: SpecialOffersView()),
                        NavigationOption(title: "Loyalty Program", iconName: "star.fill", destination: LoyaltyProgramView())
                    ])
                }


                // Logout Option
                Button(action: {
                    authViewModel.signOut()
                }) {
                    HStack {
                        Image(systemName: "arrow.right.circle")
                            .font(.title2)
                        Text("Logout")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(15)
                }
                .padding(.vertical, 20)
            }
            .padding()
            .background(Color(.systemBackground))
        }
        .onAppear {
            // Fetch the user's profile when the view appears
            if let userId = authViewModel.auth.currentUser?.uid {
                authViewModel.fetchUserProfile(userId: userId)
            }
        }
    }
}

struct SectionView: View {
    var title: String
    var options: [NavigationOption]

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.leading, 15)

            ForEach(options) { option in
                NavigationLink(destination: option.destination) {
                    MoreOptionView(title: option.title, iconName: option.iconName)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

struct NavigationOption: Identifiable {
    var id = UUID()
    var title: String
    var iconName: String
    var destination: AnyView

    init<Content: View>(title: String, iconName: String, destination: Content) {
        self.title = title
        self.iconName = iconName
        self.destination = AnyView(destination)
    }
}


struct MoreView_Previews: PreviewProvider {
    static var previews: some View {
        MoreView()
            .environmentObject(AuthViewModel()) // Provide a test AuthViewModel for the preview
    }
}
