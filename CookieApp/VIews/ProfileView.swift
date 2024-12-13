import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isEditing = false
    @State private var newName = ""
    @State private var newEmail = ""
    @State private var newPhone = ""
    @State private var newAddress = ""
    @State private var showDeleteAlert = false
    @State private var showImagePicker = false
    @State private var selectedImageName: String?

    // Preloaded profile picture options
    let profileImages = ["Cookie1", "Cookie2", "Cookie3", "Cookie4", "Cookie5", "Cookie6"] // Image names in assets

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile Picture Section
                VStack(spacing: 8) {
                    if let profileImageName = selectedImageName ?? authViewModel.profilePictureURL {
                        Image(profileImageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.gray)
                    }

                    Button(action: {
                        showImagePicker = true
                    }) {
                        Text("Change Profile Picture")
                            .font(.footnote)
                            .foregroundColor(.blue)
                    }
                }

                // Show Image Picker Grid
                if showImagePicker {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                            ForEach(profileImages, id: \.self) { imageName in
                                Button(action: {
                                    selectedImageName = imageName
                                    saveSelectedImage(imageName: imageName)
                                    showImagePicker = false
                                }) {
                                    Image(imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                                }
                            }
                        }
                        .padding()
                    }
                }

                Divider()

                // Profile Information Section
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

                        TextField("Enter your address (optional)", text: $newAddress)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                    } else {
                        Text(authViewModel.userName.isEmpty ? "No Name" : authViewModel.userName)
                            .font(.title)
                            .fontWeight(.bold)

                        Text(authViewModel.userEmail.isEmpty ? "No Email" : authViewModel.userEmail)
                            .foregroundColor(.gray)

                        if !authViewModel.userPhone.isEmpty {
                            Text(authViewModel.userPhone)
                                .foregroundColor(.gray)
                        }

                        if !authViewModel.address.isEmpty {
                            Text(authViewModel.address)
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
                    if isEditing {
                        authViewModel.updateProfile(
                            name: newName.isEmpty ? nil : newName,
                            email: newEmail.isEmpty ? nil : newEmail,
                            phone: newPhone.isEmpty ? nil : newPhone,
                            address: newAddress.isEmpty ? nil : ["street": newAddress] // Assuming `newAddress` is the street field
                        ) { success, errorMessage in
                            if success {
                                isEditing = false
                            } else {
                                authViewModel.errorMessage = errorMessage
                            }
                        }
                    } else {
                        // Populate fields with current data
                        newName = authViewModel.userName
                        newEmail = authViewModel.userEmail
                        newPhone = authViewModel.userPhone
                        newAddress = authViewModel.address
                    }
                }) {
                    Text(isEditing ? "Save Changes" : "Edit Profile")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isEditing ? Color.green : Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .background(Color(red: 1.0, green: 1.0, blue: 0.8))
        .navigationTitle("Profile Management")
        .onAppear {
            loadSelectedImage()
        }
    }

    // Save the selected image name
    private func saveSelectedImage(imageName: String) {
        UserDefaults.standard.set(imageName, forKey: "selectedProfileImage")
    }

    // Load the selected image name
    private func loadSelectedImage() {
        if let savedImageName = UserDefaults.standard.string(forKey: "selectedProfileImage") {
            selectedImageName = savedImageName
        }
    }
}
