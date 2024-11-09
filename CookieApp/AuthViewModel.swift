//
//  AuthViewModel.swift
//  CookieApp
//
//  Created by Peniel Babah on 11/8/24.
//
import SwiftUI
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var isSignedIn = false
    @Published var errorMessage: String?
    @Published var user: User?

    init() {
        self.isSignedIn = Auth.auth().currentUser != nil
        self.user = Auth.auth().currentUser
    }

    func signUp(email: String, password: String, firstName: String, lastName: String, birthdate: Date) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            } else {
                self.updateProfile(firstName: firstName, lastName: lastName, birthdate: birthdate)
                DispatchQueue.main.async {
                    self.isSignedIn = true
                    self.user = result?.user
                }
            }
        }
    }

    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            } else {
                DispatchQueue.main.async {
                    self.isSignedIn = true
                    self.user = result?.user
                }
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.isSignedIn = false
                self.user = nil
            }
        } catch let signOutError as NSError {
            DispatchQueue.main.async {
                self.errorMessage = "Error signing out: \(signOutError.localizedDescription)"
            }
        }
    }

    func resetPassword(email: String) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Password reset email sent."
                }
            }
        }
    }

    private func updateProfile(firstName: String, lastName: String, birthdate: Date) {
        guard let user = Auth.auth().currentUser else { return }
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = "\(firstName) \(lastName)"
        changeRequest.commitChanges { error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
        // Save birthdate to Firestore or Realtime Database as needed
    }
}
