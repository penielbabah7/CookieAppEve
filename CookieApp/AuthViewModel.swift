//
//  AuthViewModel.swift
//  CookieApp
//
//  Created by Peniel Babah on 11/8/24.
//
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import AuthenticationServices
import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var isSignedIn = false
    @Published var errorMessage: String?
    @Published var userName: String = ""
    @Published var userEmail: String = ""
    @Published var userPhone: String = ""
    @Published var birthdate: Date?
    @Published var loyaltyPoints: Int = 0
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

    // MARK: - Email Authentication
    func signUp(email: String, password: String, firstName: String, lastName: String, birthdate: Date) {
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
                self.updateProfile(name: "Updated Name", email: "example@example.com", phone: "123-456-7890")
                DispatchQueue.main.async {
                    self.isSignedIn = true
                }
            }
        }
    }

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
                DispatchQueue.main.async {
                    self.isSignedIn = true
                    self.fetchUserProfile(userId: user.uid)
                }
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.isSignedIn = false
                self.userName = ""
                self.userEmail = ""
                self.userPhone = ""
                self.birthdate = nil
                self.loyaltyPoints = 0
                self.profilePictureURL = nil
            }
        } catch let signOutError as NSError {
            DispatchQueue.main.async {
                self.errorMessage = "Error signing out: \(signOutError.localizedDescription)"
            }
        }
    }

    func resetPassword(email: String) {
        isLoading = true
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            self.isLoading = false
            DispatchQueue.main.async {
                self.errorMessage = error?.localizedDescription ?? "Password reset email sent."
            }
        }
    }

    // MARK: - Change Password
    func changePassword(currentPassword: String, newPassword: String) {
        guard let email = Auth.auth().currentUser?.email else {
            self.errorMessage = "No user logged in."
            return
        }

        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        Auth.auth().currentUser?.reauthenticate(with: credential) { _, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Reauthentication failed: \(error.localizedDescription)"
                }
                return
            }

            Auth.auth().currentUser?.updatePassword(to: newPassword) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.errorMessage = "Password update failed: \(error.localizedDescription)"
                    } else {
                        self.errorMessage = "Password successfully updated!"
                    }
                }
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
                    self.userName = ""
                    self.userEmail = ""
                    self.userPhone = ""
                    self.birthdate = nil
                    self.loyaltyPoints = 0
                    self.profilePictureURL = nil
                    self.errorMessage = "Account successfully deleted."
                }
            }
        }
    }

    // MARK: - Public Update Profile
    func updateProfile(name: String?, email: String?, phone: String?) {
        guard let userId = Auth.auth().currentUser?.uid else {
            self.errorMessage = "No user logged in."
            return
        }

        var updatedData: [String: Any] = [:]

        if let name = name {
            let nameComponents = name.split(separator: " ", maxSplits: 1)
            updatedData["firstName"] = nameComponents.first ?? ""
            updatedData["lastName"] = nameComponents.last ?? ""
            self.userName = name
        }

        if let email = email {
            Auth.auth().currentUser?.updateEmail(to: email) { error in
                if let error = error {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to update email: \(error.localizedDescription)"
                    }
                } else {
                    DispatchQueue.main.async {
                        self.userEmail = email
                    }
                }
            }
        }

        if let phone = phone {
            updatedData["phone"] = phone
            self.userPhone = phone
        }

        db.collection("users").document(userId).updateData(updatedData) { error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to update profile: \(error.localizedDescription)"
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Profile successfully updated!"
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

    // MARK: - Profile Picture Upload
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
                    DispatchQueue.main.async {
                        if let error = error {
                            self.errorMessage = "Failed to update profile picture URL: \(error.localizedDescription)"
                        } else {
                            self.profilePictureURL = url.absoluteString
                        }
                    }
                }
            }
        }
    }
}
