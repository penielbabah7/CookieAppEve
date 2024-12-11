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
    @Published var isSignedIn: Bool = false
    @Published var isGracePeriodActive: Bool = false
    @Published var isEmailVerificationInProgress: Bool = false // New state
    @Published var errorMessage: String?
    @Published var userName: String = ""
    @Published var userEmail: String = ""
    @Published var userPhone: String = ""
    @Published var address: String = ""
    @Published var birthdate: Date?
    @Published var loyaltyPoints: Int = 0
    @Published var profilePictureURL: String?
    @Published var isLoading: Bool = false


    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    let auth = Auth.auth()
    
    var currentUserId: String? {
            return auth.currentUser?.uid
        }


    init() {
        self.checkAuthState()
    }

    // MARK: - Check Authentication State
    func checkAuthState() {
        isGracePeriodActive = false
            isLoading = true
            if let user = auth.currentUser {
                user.reload { error in
                    DispatchQueue.main.async {
                        self.isLoading = false
                        // Only update isSignedIn if the user is fully verified
                        if error == nil && user.isEmailVerified {
                            self.isSignedIn = true
                        } else {
                            self.isSignedIn = false
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.isSignedIn = false
                }
            }
        }
    
    func signIn(email: String, password: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = "Sign In Failed: \(error.localizedDescription)"
                    completion(false)
                } else if result?.user != nil {
                    self?.isSignedIn = true
                    completion(true)
                } else {
                    self?.errorMessage = "Unexpected error occurred. Please try again."
                    completion(false)
                }
            }
        }
    }

    // MARK: - Sign Up
    func signUp(email: String, password: String, firstName: String, lastName: String, birthdate: Date, address: String, phone: String) {
        isLoading = true
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            self.isLoading = false
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Signup failed: \(error.localizedDescription)"
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
                            self.errorMessage = "Failed to save user data: \(error.localizedDescription)"
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
    
    // Update Profile Method
        func updateProfile(name: String?, email: String?, phone: String?, address: String?, completion: @escaping (Bool, String?) -> Void) {
            guard let userId = Auth.auth().currentUser?.uid else {
                completion(false, "No user logged in.")
                return
            }

            var updatedData: [String: Any] = [:]

            if let name = name {
                updatedData["name"] = name
                self.userName = name
            }

            if let email = email {
                // Attempt to update email in FirebaseAuth
                Auth.auth().currentUser?.updateEmail(to: email) { error in
                    if let error = error {
                        completion(false, "Failed to update email: \(error.localizedDescription)")
                    } else {
                        updatedData["email"] = email
                        self.userEmail = email
                    }
                }
            }

            if let phone = phone {
                updatedData["phone"] = phone
                self.userPhone = phone
            }

            if let address = address {
                updatedData["address"] = address
                self.address = address
            }

            db.collection("users").document(userId).updateData(updatedData) { error in
                if let error = error {
                    completion(false, "Failed to update profile: \(error.localizedDescription)")
                } else {
                    completion(true, nil)
                }
            }
        }
    

    // Function to sign up a new user
    func createUser(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        isLoading = true
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if let error = error {
                    self?.errorMessage = "Signup failed: \(error.localizedDescription)"
                    completion(false, error.localizedDescription)
                    return
                }

                // If account creation is successful
                if let _ = result?.user {
                    self?.isSignedIn = true
                    completion(true, nil)
                } else {
                    completion(false, "Unknown error occurred.")
                }
            }
        }
    }

    // Function to handle sign-in
    func signIn(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        isLoading = true
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] _, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if let error = error {
                    self?.errorMessage = "Sign In Failed: \(error.localizedDescription)"
                    completion(false, error.localizedDescription)
                    return
                }

                // If sign-in is successful
                self?.isSignedIn = true
                completion(true, nil)
            }
        }
    }


    func checkEmailVerification(completion: @escaping (Bool) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(false)
            errorMessage = "No user is currently logged in."
            return
        }

        user.reload { error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Failed to reload user: \(error.localizedDescription)"
                    completion(false)
                } else {
                    if user.isEmailVerified {
                        self.isGracePeriodActive = false
                        self.isSignedIn = true
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            }
        }
    }


    // MARK: - Phone Verification
    func sendPhoneVerification(phoneNumber: String, completion: @escaping (Bool) -> Void) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to send phone verification: \(error.localizedDescription)"
                    completion(false) // Indicate failure
                }
            } else {
                UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                DispatchQueue.main.async {
                    self.errorMessage = "Verification code sent to \(phoneNumber)."
                    completion(true) // Indicate success
                }
            }
        }
    }



    func verifyPhoneCode(verificationCode: String, completion: @escaping (Bool) -> Void) {
        guard let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") else {
            self.errorMessage = "Verification ID not found."
            completion(false)
            return
        }

        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: verificationCode)

        Auth.auth().signIn(with: credential) { authResult, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Failed to verify phone number: \(error.localizedDescription)"
                    completion(false)
                } else {
                    self.errorMessage = nil
                    completion(true)
                }
            }
        }
    }

    // MARK: - Fetch User Profile
    func fetchUserProfile(userId: String) {
        let userDocRef = db.collection("users").document(userId)
        userDocRef.getDocument { document, error in
            if let document = document, document.exists, let data = document.data() {
                DispatchQueue.main.async {
                    self.userName = data["firstName"] as? String ?? ""
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
    
    



    // MARK: - Reset Password
    func resetPassword(email: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(false, error.localizedDescription)
                } else {
                    completion(true, nil)
                }
            }
        }
    }


    // MARK: - Delete Account
    func deleteAccount() {
        guard let user = Auth.auth().currentUser else {
            self.errorMessage = "No user is logged in."
            return
        }

        user.delete { error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to delete account: \(error.localizedDescription)"
                }
            } else {
                DispatchQueue.main.async {
                    self.isSignedIn = false
                    self.clearUserData()
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
        } catch let error as NSError {
            DispatchQueue.main.async {
                self.errorMessage = "Error signing out: \(error.localizedDescription)"
            }
        }
    }
    
    func changePassword(currentPassword: String, newPassword: String, completion: @escaping (Bool, String?) -> Void) {
            guard let email = Auth.auth().currentUser?.email else {
                completion(false, "No user logged in.")
                return
            }

            let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)

            // Re-authenticate the user before changing the password
            Auth.auth().currentUser?.reauthenticate(with: credential) { result, error in
                if let error = error {
                    completion(false, "Reauthentication failed: \(error.localizedDescription)")
                    return
                }

                // Update the password after successful reauthentication
                Auth.auth().currentUser?.updatePassword(to: newPassword) { error in
                    if let error = error {
                        completion(false, "Password update failed: \(error.localizedDescription)")
                    } else {
                        completion(true, nil) // Password changed successfully
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
