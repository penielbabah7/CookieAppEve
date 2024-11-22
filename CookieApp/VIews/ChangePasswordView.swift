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
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        VStack {
            SecureField("Current Password", text: $currentPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            SecureField("New Password", text: $newPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            SecureField("Confirm New Password", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                if newPassword == confirmPassword {
                    authViewModel.changePassword(currentPassword: currentPassword, newPassword: newPassword)
                }
            }) {
                Text("Change Password")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
        .navigationTitle("Change Password")
    }
}
