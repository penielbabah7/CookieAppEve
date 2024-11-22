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
    @DocumentID var id: String?
    var purchaseCount: Int = 0
    var rewards: [String: Bool] = [:]
    var birthdate: Date?
}

