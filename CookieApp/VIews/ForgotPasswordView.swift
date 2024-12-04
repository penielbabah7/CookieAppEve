//
//  ForgotPasswordView.swift
//  CookieApp
//
//  Created by Peniel Babah on 11/22/24.
//

import SwiftUI

struct ForgotPasswordView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var isLoading = false
    @State private var successMessage: String?

    var body: some View {
        VStack(spacing: 20) {
            Text("Forgot Password")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Enter your email address to receive a password reset link.")
                .multilineTextAlignment(.center)
                .padding()

            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .padding()

            Button(action: {
                if isValidEmail(email) {
                    isLoading = true
                    authViewModel.resetPassword(email: email) { success, message in
                        isLoading = false
                        if success {
                            successMessage = "Password reset email sent. Please check your inbox."
                        } else {
                            authViewModel.errorMessage = message ?? "Failed to send reset email."
                        }
                    }
                } else {
                    authViewModel.errorMessage = "Invalid email format."
                }
            }) {
                if isLoading {
                    ProgressView()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray)
                        .cornerRadius(10)
                } else {
                    Text("Send Reset Link")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .disabled(isLoading)

            // Success Message
            if let successMessage = successMessage {
                Text(successMessage)
                    .foregroundColor(.green)
                    .padding(.top, 10)
            }

            // Error Message
            if let errorMessage = authViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.top, 10)
            }
        }
        .padding()
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: email)
    }
}
