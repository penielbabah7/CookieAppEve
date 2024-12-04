//
//  ChangePasswordView.swift
//  CookieApp
//
//  Created by Peniel Babah on 11/20/24.
//

import SwiftUI

struct ChangePasswordView: View {
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @EnvironmentObject var authViewModel: AuthViewModel // Inject the AuthViewModel
    @State private var successMessage: String?

    var body: some View {
        VStack {
            SecureField("Current Password", text: $currentPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textContentType(.password) // Current password
                .padding()

            SecureField("New Password", text: $newPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textContentType(.newPassword) // New password field
                .padding()

            SecureField("Confirm New Password", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textContentType(.newPassword)
                .padding()


            Button(action: {
                if newPassword == confirmPassword {
                    authViewModel.changePassword(currentPassword: currentPassword, newPassword: newPassword) { success, errorMessage in
                        if success {
                            successMessage = "Password changed successfully!"
                            self.authViewModel.errorMessage = nil
                        } else {
                            self.authViewModel.errorMessage = errorMessage
                            successMessage = nil
                        }
                    }
                } else {
                    authViewModel.errorMessage = "Passwords do not match!"
                    successMessage = nil
                }
            }) {
                Text("Change Password")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()

            // Show success or error message
            if let successMessage = successMessage {
                Text(successMessage)
                    .foregroundColor(.green)
                    .padding(.top, 10)
            }

            if let errorMessage = authViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.top, 10)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Change Password")
    }
}
