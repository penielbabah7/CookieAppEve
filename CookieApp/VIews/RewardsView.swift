//
//  RewardsView.swift
//  EvesOriginalSinCookies
//
//  Created by Daniel Baroi on 10/5/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct RewardsView: View {
    @State private var purchaseCount: Int = 0
    private let requiredPurchases = 6
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            // Background Image
            Image("Toppings Falling") // Replace with your actual image name
                .resizable()
                .ignoresSafeArea()
                .opacity(0.3)

            if isLoading {
                ProgressView("Loading Rewards...")
                    .padding()
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        Text("Rewards")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .padding(.top, 20)

                        // Progress Section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Your Progress")
                                .font(.headline)
                                .foregroundColor(.secondary)

                            ProgressView(value: Double(purchaseCount), total: Double(requiredPurchases))
                                .progressViewStyle(LinearProgressViewStyle(tint: Color.blue))
                                .frame(height: 20)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)

                            Text("You have \(purchaseCount) out of \(requiredPurchases) purchases towards a free cookie!")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(15)
                        .shadow(radius: 5)
                        .padding(.horizontal)

                        // Rewards List Section
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Available Rewards")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .padding(.leading, 20)

                            ForEach(rewardsData) { reward in
                                RewardRow(reward: reward, isUnlocked: reward.isUnlocked(purchaseCount, requiredPurchases)) {
                                    redeemReward(reward: reward)
                                }
                                .padding(.horizontal)
                            }
                        }

                        Spacer()
                    }
                    .background(Color(.systemBackground))
                }
            }
        }
        .onAppear {
            fetchPurchaseCount()
            NotificationCenter.default.addObserver(forName: NSNotification.Name("RewardsUpdated"), object: nil, queue: .main) { _ in
                fetchPurchaseCount()
            }
        }
        .alert(isPresented: .constant(errorMessage != nil)) {
            Alert(
                title: Text("Error"),
                message: Text(errorMessage ?? "An unknown error occurred."),
                dismissButton: .default(Text("OK"), action: { errorMessage = nil })
            )
        }
    }

    // MARK: - Fetch Purchase Count
    private func fetchPurchaseCount() {
            guard let userId = Auth.auth().currentUser?.uid else {
                print("No user ID found.")
                self.isLoading = false
                return
            }

            let db = Firestore.firestore()
            db.collection("users").document(userId).getDocument { snapshot, error in
                if let error = error {
                    print("Failed to fetch purchase count: \(error.localizedDescription)")
                    self.isLoading = false
                } else if let data = snapshot?.data(), let count = data["purchaseCount"] as? Int {
                    self.purchaseCount = count
                    self.isLoading = false
                } else {
                    print("No purchase count found for user.")
                    self.isLoading = false
                }
            }
        }
    
    

    // MARK: - Redeem Reward
    private func redeemReward(reward: Reward) {
        guard reward.rewardName == "Free Cookie", purchaseCount >= requiredPurchases else { return }

        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "You must be signed in to redeem rewards."
            return
        }

        // Select a random "Cookie of the Month"
        let cookieOptions = ["Chocolate Chip", "Peanut Butter", "Oatmeal Raisin", "Snickerdoodle", "Macadamia Nut"]
        guard let randomCookie = cookieOptions.randomElement() else {
            errorMessage = "Failed to select a Cookie of the Month."
            return
        }

        let db = Firestore.firestore()

        // Create a new order for the free cookie
        let freeCookieOrder: [String: Any] = [
            "userId": userId,
            "items": [randomCookie: 1],
            "totalAmount": 0.0, // Free cookie
            "totalCookiesInOrder": 1,
            "paymentMethod": "Redeemed Reward",
            "paymentStatus": "confirmed",
            "timestamp": FieldValue.serverTimestamp()
        ]

        db.collection("orders").addDocument(data: freeCookieOrder) { error in
            if let error = error {
                errorMessage = "Failed to redeem reward: \(error.localizedDescription)"
            } else {
                // Deduct the required purchase count and update the progress
                db.collection("users").document(userId).updateData([
                    "purchaseCount": FieldValue.increment(Int64(-requiredPurchases))
                ]) { error in
                    if let error = error {
                        errorMessage = "Failed to update purchase count: \(error.localizedDescription)"
                    } else {
                        purchaseCount -= requiredPurchases
                        print("Successfully redeemed free cookie reward! Cookie: \(randomCookie)")

                        // Notify the user
                        showAlert(message: "Congratulations! You have redeemed a free cookie. Enjoy your \(randomCookie).")
                    }
                }
            }
        }
    }

    // Helper function to show alerts
    private func showAlert(message: String) {
        DispatchQueue.main.async {
            errorMessage = message
        }
    }


}

struct RewardRow: View {
    var reward: Reward
    var isUnlocked: Bool
    var onRedeem: () -> Void

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: reward.iconName)
                .foregroundColor(isUnlocked ? .blue : .gray)
                .font(.title2)

            VStack(alignment: .leading) {
                Text(reward.rewardName)
                    .font(.headline)
                    .foregroundColor(isUnlocked ? .primary : .secondary)
                Text(reward.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: {
                if isUnlocked {
                    onRedeem()
                }
            }) {
                Text(isUnlocked ? "Redeem" : "Locked")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 8)
                    .background(isUnlocked ? Color.blue : Color(.systemGray5))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(!isUnlocked)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

struct Reward: Identifiable {
    var id = UUID()
    var rewardName: String
    var iconName: String
    var description: String
    var isUnlocked: (_ purchaseCount: Int, _ requiredPurchases: Int) -> Bool
}

let rewardsData = [
    Reward(rewardName: "Free Cookie", iconName: "gift.fill", description: "Get a free cookie after 6 purchases.", isUnlocked: { cookiesBought, required in
        cookiesBought >= required
    }),
    Reward(rewardName: "Seasonal Flavor Preview", iconName: "leaf.fill", description: "Try new seasonal flavors before anyone else.", isUnlocked: { _, _ in false }),
    Reward(rewardName: "Birthday Reward", iconName: "birthday.cake.fill", description: "Celebrate with a free birthday treat.", isUnlocked: { _, _ in false }),
    Reward(rewardName: "Cookie of the Month", iconName: "star.fill", description: "Receive the cookie of the month as a reward.", isUnlocked: { _, _ in false }),
    Reward(rewardName: "Referral Reward", iconName: "person.3.fill", description: "Refer friends and earn exclusive rewards.", isUnlocked: { _, _ in false })
]

struct RewardsView_Previews: PreviewProvider {
    static var previews: some View {
        RewardsView()
    }
}
