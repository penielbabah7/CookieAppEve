//
//  UserData.swift
//  CookieApp
//
//  Created by Peniel Babah on 11/11/24.
//

// UserData.swift

import Foundation
import FirebaseFirestore

struct UserData: Codable {
    @DocumentID var id: String? // Automatically maps Firestore document ID
    var purchaseCount: Int = 0 // Tracks the number of purchases
    var rewards: [String: Bool] = [:] // Tracks rewards (e.g., ["freeCookie": true])
    var birthdate: Date? // Optional birthdate field
    var address: String? // Add address if required
}
