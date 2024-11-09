//
//  SignInView.swift
//  CookieApp
//
//  Created by Peniel Babah on 11/8/24.
//

import SwiftUI

struct SignInView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationView { // Wrap in NavigationView for navigation capabilities
            VStack(spacing: 20) {
                Text("Sign In")
                    .font(.largeTitle)
                    .bold()

                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button(action: {
                    authViewModel.signIn(email: email, password: password)
                }) {
                    Text("Sign In")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }

                Button(action: {
                    authViewModel.resetPassword(email: email)
                }) {
                    Text("Forgot Password?")
                        .foregroundColor(.blue)
                }
                
                // Show error message if there's one
                if let errorMessage = authViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
                
                Spacer()
                
                // New customer sign-up prompt
                HStack {
                    Text("New customer?")
                    NavigationLink(destination: SignUpView()) { // Link to SignUpView
                        Text("Create Account")
                            .foregroundColor(.blue)
                            .underline()
                    }
                }
            }
            .padding()
        }
    }
}
