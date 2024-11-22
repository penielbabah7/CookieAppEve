//
//  AuthViewModel.swift
//  CookieApp
//
//  Created by Peniel Babah on 11/8/24.
//
//
//  AuthViewModel.swift
//  CookieApp
//
//  Created by Peniel Babah on 11/8/24.
//
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var isSignedIn = false
    @Published var errorMessage: String?
    @Published var userName: String = ""
    @Published var userEmail: String = ""
    @Published var userPhone: String = ""
    @Published var birthdate: Date?
    @Published var loyaltyPoints: Int = 0
    @Published var address: String = ""
    @Published var profilePictureURL: String?
    @Published var isLoading = false

    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    // MARK: - Initializer
    init() {
        self.isSignedIn = Auth.auth().currentUser != nil
        if let user = Auth.auth().currentUser {
            fetchUserProfile(userId: user.uid)
        }
    }

    // MARK: - Sign Up
    func signUp(email: String, password: String, firstName: String, lastName: String, birthdate: Date, address: String, phone: String) {
        isLoading = true
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            self.isLoading = false
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
                return
            }
            if let user = result?.user {
                let userData: [String: Any] = [
                    "firstName": firstName,
                    "lastName": lastName,
                    "email": email,
                    "phone": phone,
                    "birthdate": Timestamp(date: birthdate),
                    "address": address,
                    "loyaltyPoints": 0,
                    "profilePictureURL": ""
                ]
                self.db.collection("users").document(user.uid).setData(userData) { error in
                    if let error = error {
                        DispatchQueue.main.async {
                            self.errorMessage = "Error saving user data: \(error.localizedDescription)"
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.userName = "\(firstName) \(lastName)"
                            self.userEmail = email
                            self.userPhone = phone
                            self.birthdate = birthdate
                            self.address = address
                            self.isSignedIn = true
                        }
                    }
                }
            }
        }
    }

    // MARK: - Sign In
    func signIn(email: String, password: String) {
        isLoading = true
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            self.isLoading = false
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
                return
            }
            if let user = result?.user {
                self.fetchUserProfile(userId: user.uid)
                DispatchQueue.main.async {
                    self.isSignedIn = true
                }
            }
        }
    }

    // MARK: - Sign Out
    func signOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.isSignedIn = false
                self.clearUserData()
            }
        } catch let signOutError as NSError {
            DispatchQueue.main.async {
                self.errorMessage = "Error signing out: \(signOutError.localizedDescription)"
            }
        }
    }

    // MARK: - Reset Password
    func resetPassword(email: String) {
        isLoading = true
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            self.isLoading = false
            DispatchQueue.main.async {
                self.errorMessage = error?.localizedDescription ?? "Password reset email sent."
            }
        }
    }

    // MARK: - Delete Account
    func deleteAccount() {
        guard let user = Auth.auth().currentUser else {
            self.errorMessage = "No user logged in."
            return
        }

        user.delete { error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Account deletion failed: \(error.localizedDescription)"
                } else {
                    self.isSignedIn = false
                    self.clearUserData()
                }
            }
        }
    }

    // MARK: - Fetch User Profile
    private func fetchUserProfile(userId: String) {
        let userDocRef = db.collection("users").document(userId)
        userDocRef.getDocument { document, error in
            if let document = document, document.exists, let data = document.data() {
                DispatchQueue.main.async {
                    self.userName = "\(data["firstName"] as? String ?? "") \(data["lastName"] as? String ?? "")"
                    self.userEmail = data["email"] as? String ?? ""
                    self.userPhone = data["phone"] as? String ?? ""
                    self.birthdate = (data["birthdate"] as? Timestamp)?.dateValue()
                    self.address = data["address"] as? String ?? ""
                    self.loyaltyPoints = data["loyaltyPoints"] as? Int ?? 0
                    self.profilePictureURL = data["profilePictureURL"] as? String
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = error?.localizedDescription ?? "User profile not found."
                }
            }
        }
    }

    // MARK: - Update Profile
    func updateProfile(firstName: String?, lastName: String?, phone: String?, address: String?) {
        guard let userId = Auth.auth().currentUser?.uid else {
            self.errorMessage = "No user logged in."
            return
        }

        var updatedData: [String: Any] = [:]

        if let firstName = firstName {
            updatedData["firstName"] = firstName
        }

        if let lastName = lastName {
            updatedData["lastName"] = lastName
        }

        if let phone = phone {
            updatedData["phone"] = phone
        }

        if let address = address {
            updatedData["address"] = address
        }

        db.collection("users").document(userId).updateData(updatedData) { error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to update profile: \(error.localizedDescription)"
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Profile successfully updated!"
                    if let firstName = firstName, let lastName = lastName {
                        self.userName = "\(firstName) \(lastName)"
                    }
                    if let phone = phone {
                        self.userPhone = phone
                    }
                    if let address = address {
                        self.address = address
                    }
                }
            }
        }
    }

    // MARK: - Upload Profile Picture
    func uploadProfilePicture(image: UIImage) {
        guard let userId = Auth.auth().currentUser?.uid,
              let imageData = image.jpegData(compressionQuality: 0.8) else { return }

        let storageRef = storage.reference().child("profile_pictures/\(userId).jpg")
        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to upload image: \(error.localizedDescription)"
                }
                return
            }
            storageRef.downloadURL { url, error in
                if let error = error {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to retrieve image URL: \(error.localizedDescription)"
                    }
                    return
                }
                guard let url = url else { return }
                self.db.collection("users").document(userId).updateData(["profilePictureURL": url.absoluteString]) { error in
                    if let error = error {
                        DispatchQueue.main.async {
                            self.errorMessage = "Failed to update profile picture URL: \(error.localizedDescription)"
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.profilePictureURL = url.absoluteString
                        }
                    }
                }
            }
        }
    }

    // MARK: - Clear User Data
    private func clearUserData() {
        self.userName = ""
        self.userEmail = ""
        self.userPhone = ""
        self.birthdate = nil
        self.address = ""
        self.loyaltyPoints = 0
        self.profilePictureURL = nil
    }
}
