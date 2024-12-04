//
//  SignUpViewModel.swift
//  CookieApp
//
//  Created by Peniel Babah on 11/22/24.
//
import SwiftUI

class SignUpViewModel: ObservableObject {
    @Published var currentStep: Int = 1
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var birthday: Date = Date()
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var address: String = ""
    @Published var city: String = ""
    @Published var state: String = ""
    @Published var zipCode: String = ""
    @Published var errorMessage: String?
    @Published var showError: Bool = false

    // Validation state for Next button
    var canProceedToNextStep: Bool {
        switch currentStep {
        case 1: return !firstName.isEmpty && !lastName.isEmpty
        case 2: return Calendar.current.dateComponents([.year], from: birthday, to: Date()).year ?? 0 >= 13
        case 3: return isValidEmail(email) && !password.isEmpty && password == confirmPassword
        case 4: return !address.isEmpty && !city.isEmpty && !state.isEmpty && !zipCode.isEmpty
        default: return false
        }
    }

    func validateStep1() -> Bool {
        if firstName.isEmpty || lastName.isEmpty {
            errorMessage = "First and last name are required."
            showError = true
            return false
        }
        return true
    }

    func validateStep2() -> Bool {
        let age = Calendar.current.dateComponents([.year], from: birthday, to: Date()).year ?? 0
        if age < 13 {
            errorMessage = "You must be at least 13 years old to sign up."
            showError = true
            return false
        }
        return true
    }

    func validateStep3() -> Bool {
        if !isValidEmail(email) {
            errorMessage = "Invalid email address."
            showError = true
            return false
        }
        if password.isEmpty || confirmPassword.isEmpty || password != confirmPassword {
            errorMessage = "Passwords must match and cannot be empty."
            showError = true
            return false
        }
        return true
    }

    func validateStep4() -> Bool {
        if address.isEmpty || city.isEmpty || state.isEmpty || zipCode.isEmpty {
            errorMessage = "Complete address is required."
            showError = true
            return false
        }
        return true
    }

    func proceedToNextStep() {
        switch currentStep {
        case 1:
            if validateStep1() { currentStep += 1 }
        case 2:
            if validateStep2() { currentStep += 1 }
        case 3:
            if validateStep3() { currentStep += 1 }
        case 4:
            if validateStep4() {
                sendConfirmationEmail()
                print("Sign-up process complete!")
            }
        default:
            break
        }
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: email)
    }

    private func sendConfirmationEmail() {
        // This is a placeholder for sending a confirmation email.
        // Replace this with your email service logic.
        print("Confirmation email sent to \(email).")
    }
}
