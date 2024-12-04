//
//  SignInView.swift
//  CookieApp
//
//  Created by Peniel Babah on 11/8/24.
//

import SwiftUI

struct SignInView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUpActive = false
    @State private var showForgotPasswordSheet = false
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Sign In")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .padding()

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button(action: {
                    if isValidEmail(email) {
                        isLoading = true
                        authViewModel.signIn(email: email, password: password) { success in
                            isLoading = false
                            if !success {
                                authViewModel.errorMessage = "Failed to sign in. Check your credentials."
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
                        Text("Sign In")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .disabled(isLoading)

                if let errorMessage = authViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.top, 10)
                }

                Button(action: {
                    showForgotPasswordSheet.toggle()
                }) {
                    Text("Forgot Password?")
                        .foregroundColor(.blue)
                }
                .sheet(isPresented: $showForgotPasswordSheet) {
                    ForgotPasswordView()
                        .environmentObject(authViewModel)
                }

                Spacer()

                NavigationLink(destination: SignUpFlowView()
                                .environmentObject(authViewModel)
                                .environmentObject(SignUpViewModel()), isActive: $isSignUpActive) {
                    Button(action: {
                        isSignUpActive = true
                    }) {
                        Text("Create Account")
                            .foregroundColor(.blue)
                            .padding()
                    }
                }
            }
            .padding()
        }
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: email)
    }
}
