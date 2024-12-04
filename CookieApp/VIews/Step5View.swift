//
//  Step5View.swift
//  CookieApp
//
//  Created by Peniel Babah on 12/2/24.
//

import SwiftUI
import CoreLocation

struct Step5View: View {
    @EnvironmentObject var signUpViewModel: SignUpViewModel
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var verificationCode = ""
    @State private var isCodeSent = false // To track if the code has been sent
    @State private var isVerifying = false // To track if the verification process is in progress
    @State private var showProgress = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Verify Your Phone Number")
                .font(.title)
                .bold()

            // Phone Number Input
            TextField("Phone Number (+1234567890)", text: $signUpViewModel.phone)
                .keyboardType(.phonePad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .disabled(isCodeSent) // Disable phone number input after code is sent

            // Send Verification Code Button
            Button(action: {
                handleSendVerificationCode()
            }) {
                Text(isCodeSent ? "Resend Code" : "Send Verification Code")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isCodeSent ? Color.orange : Color.blue)
                    .cornerRadius(10)
            }
            .disabled(showProgress || signUpViewModel.phone.isEmpty)

            // Verification Code Input
            if isCodeSent {
                TextField("Enter Verification Code", text: $verificationCode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
            }

            // Verify Code Button
            if isCodeSent {
                Button(action: {
                    handleVerifyCode()
                }) {
                    Text("Verify Code")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(10)
                }
                .disabled(verificationCode.isEmpty || showProgress)
            }

            // Progress Indicator
            if showProgress {
                ProgressView()
                    .padding()
            }

            // Error Message
            if let errorMessage = signUpViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            Spacer()
        }
        .padding()
    }

    private func handleSendVerificationCode() {
        guard isValidPhone(signUpViewModel.phone) else {
            signUpViewModel.errorMessage = "Invalid phone number format. Use E.164 format (+1234567890)."
            return
        }

        signUpViewModel.errorMessage = nil
        showProgress = true

        authViewModel.sendPhoneVerification(phoneNumber: signUpViewModel.phone) { success in
            DispatchQueue.main.async {
                showProgress = false
                if success {
                    isCodeSent = true
                    signUpViewModel.errorMessage = nil
                } else {
                    signUpViewModel.errorMessage = authViewModel.errorMessage ?? "Failed to send verification code."
                }
            }
        }
    }


    private func handleVerifyCode() {
        guard !verificationCode.isEmpty else {
            signUpViewModel.errorMessage = "Please enter the verification code."
            return
        }

        showProgress = true
        authViewModel.verifyPhoneCode(verificationCode: verificationCode) { success in
            DispatchQueue.main.async {
                showProgress = false
                if success {
                    signUpViewModel.currentStep += 1 // Proceed to the next step
                } else {
                    signUpViewModel.errorMessage = "Invalid verification code. Please try again."
                }
            }
        }
    }

    private func isValidPhone(_ phone: String) -> Bool {
        // Validate phone number format (E.164 format: +country_code phone_number)
        let phoneRegEx = "^\\+[1-9]{1}[0-9]{7,14}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegEx)
        return phonePredicate.evaluate(with: phone)
    }
}
