//
//  Step3View.swift
//  CookieApp
//
//  Created by Peniel Babah on 12/2/24.
//
import SwiftUI

struct Step3View: View {
    @EnvironmentObject var signUpViewModel: SignUpViewModel

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

            Button(action: handleNextStep) {
                Text("Next")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .disabled(!canProceedToNextStep)

            if let errorMessage = signUpViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            Spacer()
        }
        .padding()
    }

    private func handleNextStep() {
        guard isValidEmail(signUpViewModel.email) else {
            signUpViewModel.errorMessage = "Invalid email address."
            return
        }

        guard signUpViewModel.password == signUpViewModel.confirmPassword else {
            signUpViewModel.errorMessage = "Passwords do not match."
            return
        }

        signUpViewModel.errorMessage = nil
        signUpViewModel.currentStep += 1 // Proceed to the next step
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: email)
    }

    private var canProceedToNextStep: Bool {
        !signUpViewModel.email.isEmpty && !signUpViewModel.password.isEmpty && !signUpViewModel.confirmPassword.isEmpty
    }
}
