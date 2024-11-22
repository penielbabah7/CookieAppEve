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
    var firstName: String
    var lastName: String
    var email: String
    var phone: String
    var birthdate: Date?
    var address: String?
    var loyaltyPoints: Int = 0
}
