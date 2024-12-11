//
//  RewardsView.swift
//  EvesOriginalSinCookies
//
//  Created by Daniel Baroi on 10/5/24.
//

import SwiftUI

struct RewardsView: View {
    @State private var purchaseCount: Int = 8
    private let requiredPurchases = 12

    var body: some View {
        ZStack{
            Image("Toppings Falling") // Replace with your actual image name
                            .resizable()
                           // .scale()
                            .ignoresSafeArea()
                            .opacity(0.3)
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
                            RewardRow(reward: reward, isUnlocked: reward.isUnlocked(purchaseCount, requiredPurchases))
                                .padding(.horizontal)
                        }
                    }

                    Spacer()
                }
                .background(Color(.systemBackground))
            }
        }
        
    }
}

struct RewardRow: View {
    var reward: Reward
    var isUnlocked: Bool

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
                // Handle redemption action
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
    Reward(rewardName: "Free Cookie", iconName: "gift.fill", description: "Get a free cookie after 12 purchases.", isUnlocked: { $0 >= $1 }),
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
