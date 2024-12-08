import SwiftUI
import AVKit

struct SignInView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUpActive = false
    @State private var showForgotPasswordSheet = false
    @State private var isLoading = false
    
    private var player: AVPlayer = {
        let url = Bundle.main.url(forResource: "Woman Adding Cookies", withExtension: "mp4")!
        let player = AVPlayer(url: url)
        player.isMuted = true
        player.play()
        player.actionAtItemEnd = .none
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
            player.seek(to: .zero)
            player.play()
        }
        return player
    }()
    
    var body: some View {
        ZStack {
            // Background Video
            VideoPlayer(player: player)
                .scaledToFill()
                .edgesIgnoringSafeArea(.all) // Full-screen video
                .onAppear {
                    player.play()
                }
            
            // Foreground Content
            VStack {
                Spacer() // Push content downward
                
                VStack(spacing: 15) {
                    Text("Sign In")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    // Email TextField with custom placeholder
                    TextField("", text: $email)
                        .placeholder(when: email.isEmpty) {
                            Text("Email")
                                .foregroundColor(Color.white.opacity(0.8))
                        }
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(5)
                        .foregroundColor(.white)
                        .autocapitalization(.none)

                    // Password SecureField with custom placeholder
                    SecureField("", text: $password)
                        .placeholder(when: password.isEmpty) {
                            Text("Password")
                                .foregroundColor(Color.white.opacity(0.8))
                        }
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(5)
                        .foregroundColor(.white)

                    // Sign-In Button
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
                            .padding(.top, 5)
                    }

                    // Forgot Password Link
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
                }
                .padding()
                .background(Color.black.opacity(0.4)) // Subtle background for content visibility
                .cornerRadius(15)
                .frame(maxWidth: 350) // Adjust width to match previous size
                .padding(.horizontal, 20)

                Spacer()

                // Create Account Button
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
            .padding(.bottom, 50) // Adjust spacing to keep proportions similar
        }
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: email)
    }
}

// Placeholder Modifier for TextFields
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
