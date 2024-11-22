//
//  ProfileView.swift
//  CookieApp
//
//  Created by Peniel Babah on 11/8/24.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isEditing = false
    @State private var newName: String
    @State private var newEmail: String
    @State private var newPhone: String
    @State private var showDeleteAlert = false

    init() {
        _newName = State(initialValue: "")
        _newEmail = State(initialValue: "")
        _newPhone = State(initialValue: "")
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile Picture Section
                VStack(spacing: 8) {
                    if let profileImageURL = authViewModel.profilePictureURL,
                       let url = URL(string: profileImageURL) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                        } placeholder: {
                            ProgressView()
                                .frame(width: 120, height: 120)
                        }
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.gray)
                    }

                    Button(action: {
                        // Trigger image picker
                    }) {
                        Text("Change Profile Picture")
                            .font(.footnote)
                            .foregroundColor(.blue)
                    }
                }

                Divider()

                // Profile Information
                VStack(spacing: 10) {
                    if isEditing {
                        TextField("Enter your name", text: $newName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)

                        TextField("Enter your email", text: $newEmail)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)

                        TextField("Enter your phone (optional)", text: $newPhone)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                    } else {
                        Text(authViewModel.userName)
                            .font(.title)
                            .fontWeight(.bold)

                        Text(authViewModel.userEmail)
                            .foregroundColor(.gray)

                        if !authViewModel.userPhone.isEmpty {
                            Text(authViewModel.userPhone)
                                .foregroundColor(.gray)
                        }
                    }
                }

                Divider()

                // Manage Account Section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Manage Account")
                        .font(.headline)

                    // Change Password
                    NavigationLink(destination: ChangePasswordView()) {
                        MoreOptionView(title: "Change Password", iconName: "key.fill")
                    }

                    // Delete Account
                    Button(action: {
                        showDeleteAlert = true
                    }) {
                        MoreOptionView(title: "Delete Account", iconName: "trash.fill")
                            .foregroundColor(.red)
                    }
                    .alert(isPresented: $showDeleteAlert) {
                        Alert(
                            title: Text("Delete Account"),
                            message: Text("Are you sure you want to delete your account? This action cannot be undone."),
                            primaryButton: .destructive(Text("Delete")) {
                                authViewModel.deleteAccount()
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }
                .padding()

                Divider()

                // Edit/Save Button
                Button(action: {
                    authViewModel.updateProfile(
                        name: newName.isEmpty ? nil : newName,
                        email: newEmail.isEmpty ? nil : newEmail,
                        phone: newPhone.isEmpty ? nil : newPhone
                    )
                }) {
                    Text("Save Changes")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(10)
                }

            }
            .padding()
        }
        .background(Color(red: 1.0, green: 1.0, blue: 0.8))
        .navigationTitle("Profile Management")
    }
}
