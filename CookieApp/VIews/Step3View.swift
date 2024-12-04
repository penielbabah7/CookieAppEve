//
//  Step3View.swift
//  CookieApp
//
//  Created by Peniel Babah on 12/2/24.
//
import SwiftUI
import CoreLocation

struct Step3View: View {
    @EnvironmentObject var signUpViewModel: SignUpViewModel
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var verificationSent = false
    @State private var isCheckingVerification = false
    @State private var verificationTimer: Timer?

    var body: some View {
        VStack(spacing: 20) {
            Text("Set up your account")
                .font(.title)
                .bold()

            TextField("Email Address", text: $signUpViewModel.email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .padding()

            SecureField("Password", text: $signUpViewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            SecureField("Confirm Password", text: $signUpViewModel.confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: handleSendVerification) {
                Text("Send Verification Email")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .disabled(signUpViewModel.password.isEmpty || signUpViewModel.confirmPassword.isEmpty || signUpViewModel.email.isEmpty)

            if verificationSent {
                Text("A verification email has been sent to \(signUpViewModel.email). Please check your inbox.")
                    .foregroundColor(.green)
                    .multilineTextAlignment(.center)
                    .padding()
            }

            if isCheckingVerification {
                ProgressView("Waiting for email verification...")
                    .padding()
            }

            if let errorMessage = signUpViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            Spacer()
        }
        .padding()
        .onAppear {
            // Reset state when view appears
            verificationSent = false
            isCheckingVerification = false
            signUpViewModel.errorMessage = nil
        }
        .onDisappear {
            // Invalidate the timer if the view disappears
            verificationTimer?.invalidate()
        }
    }

    private func handleSendVerification() {
        guard isValidEmail(signUpViewModel.email) else {
            signUpViewModel.errorMessage = "Invalid email address."
            return
        }

        guard signUpViewModel.password == signUpViewModel.confirmPassword else {
            signUpViewModel.errorMessage = "Passwords do not match."
            return
        }

        // Call the method to send the verification email
        authViewModel.sendEmailVerification(email: signUpViewModel.email, password: signUpViewModel.password) { success in
            if success {
                verificationSent = true
                startVerificationCheck()
            } else {
                signUpViewModel.errorMessage = authViewModel.errorMessage
            }
        }
    }

    private func startVerificationCheck() {
        isCheckingVerification = true
        verificationTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
            authViewModel.checkEmailVerification { verified in
                if verified {
                    timer.invalidate()
                    isCheckingVerification = false
                    signUpViewModel.currentStep += 1 // Proceed to next step
                }
            }
        }

        // Stop the verification check after a timeout (e.g., 60 seconds)
        DispatchQueue.main.asyncAfter(deadline: .now() + 60) {
            if isCheckingVerification {
                verificationTimer?.invalidate()
                isCheckingVerification = false
                signUpViewModel.errorMessage = "Verification email not received. Please try again."
            }
        }
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: email)
    }
}
