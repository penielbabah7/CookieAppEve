import SwiftUI
import FirebaseAuth
import FirebaseFirestore

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
    @Published var isLoading: Bool = false // For showing loading state

    // Validation state for Next or Finish button
    var canProceedToNextStep: Bool {
        switch currentStep {
        case 1:
            return !firstName.isEmpty && !lastName.isEmpty
        case 2:
            return Calendar.current.dateComponents([.year], from: birthday, to: Date()).year ?? 0 >= 13
        case 3:
            return isValidEmail(email) && !password.isEmpty && password == confirmPassword
        case 4:
            return isValidAddress()
        default:
            return false
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
        if !isValidAddress() {
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
                completeSignUpProcess()
            }
        default:
            break
        }
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: email)
    }

    private func isValidAddress() -> Bool {
        !address.isEmpty && !city.isEmpty && !state.isEmpty && !zipCode.isEmpty
    }

    private func completeSignUpProcess() {
        isLoading = true
        createUserInFirebase { success in
            DispatchQueue.main.async {
                self.isLoading = false
                if success {
                    // Navigate to the home screen
                    UIApplication.shared.windows.first?.rootViewController = UIHostingController(rootView: MenuView())
                } else {
                    self.errorMessage = "Failed to complete sign-up. Please try again."
                    self.showError = true
                }
            }
        }
    }

    private func createUserInFirebase(completion: @escaping (Bool) -> Void) {
        // Create the user with email and password
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Sign-up failed: \(error.localizedDescription)"
                    self.showError = true
                    completion(false)
                }
                return
            }

            guard let userID = result?.user.uid else {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to retrieve user ID."
                    self.showError = true
                    completion(false)
                }
                return
            }

            // Save the user data to Firestore
            self.saveToFirestore(userID: userID, completion: completion)
        }
    }

    private func saveToFirestore(userID: String, completion: @escaping (Bool) -> Void) {
        let userData: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName,
            "email": email,
            "address": address,
            "city": city,
            "state": state,
            "zipCode": zipCode,
            "birthday": Timestamp(date: birthday)
        ]

        Firestore.firestore().collection("users").document(userID).setData(userData) { error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to save user data: \(error.localizedDescription)"
                    self.showError = true
                    completion(false)
                }
            } else {
                completion(true)
            }
        }
    }
}
