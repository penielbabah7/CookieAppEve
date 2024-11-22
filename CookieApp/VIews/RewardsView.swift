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
        VStack(spacing: 20) {
            Text("Rewards")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            ProgressView(value: Double(purchaseCount), total: Double(requiredPurchases))
                .progressViewStyle(LinearProgressViewStyle(tint: .green))
                .frame(height: 20)
                .padding()

            Text("You have \(purchaseCount) out of \(requiredPurchases) purchases towards a free cookie!")
                .font(.headline)

            List {
                RewardRow(rewardName: "Free Cookie", iconName: "gift.fill", isUnlocked: purchaseCount >= requiredPurchases)
                RewardRow(rewardName: "Seasonal Flavor Preview", iconName: "leaf.fill", isUnlocked: false)
                RewardRow(rewardName: "Birthday Reward", iconName: "birthday.cake.fill", isUnlocked: false)
                RewardRow(rewardName: "Cookie of the Month", iconName: "star.fill", isUnlocked: false)
                RewardRow(rewardName: "Referral Reward", iconName: "person.3.fill", isUnlocked: false)
            }
        }
        .padding()
        .background(Color(red: 1.0, green: 1.0, blue: 0.8)) // Custom background color
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding()
    }
}

struct RewardRow: View {
    var rewardName: String
    var iconName: String
    var isUnlocked: Bool

    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(isUnlocked ? .green : .red)
            Text(rewardName)
                .foregroundColor(isUnlocked ? .black : .gray)
            Spacer()
            Image(systemName: isUnlocked ? "lock.open.fill" : "lock.fill")
                .foregroundColor(isUnlocked ? .green : .red)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}
