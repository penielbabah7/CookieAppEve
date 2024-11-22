//
//  UserDataManager.swift
//  CookieApp
//
//  Created by Peniel Babah on 11/11/24.
//

// UserDataManager.swift

import FirebaseFirestore

class UserDataManager {
    private let db = Firestore.firestore()

    func fetchUserData(userId: String, completion: @escaping (UserData?) -> Void) {
        db.collection("users").document(userId).getDocument { document, error in
            if let document = document, document.exists {
                do {
                    let userData = try document.data(as: UserData.self) // Decoding using Codable
                    completion(userData)
                } catch {
                    print("Error decoding user data: \(error)")
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }
    }

    func saveUserData(userId: String, userData: UserData) {
        do {
            try db.collection("users").document(userId).setData(from: userData) // Encoding using Codable
        } catch {
            print("Error saving user data: \(error)")
        }
    }
}
