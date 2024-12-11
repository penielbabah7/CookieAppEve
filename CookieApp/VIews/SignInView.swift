import SwiftUI
import AVKit

struct SignInView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUpActive = false
    @State private var showForgotPasswordSheet = false

    private var player: AVPlayer = {
        let url = Bundle.main.url(forResource: "Woman Adding Cookies", withExtension: "mp4")!
        let player = AVPlayer(url: url)
        player.isMuted = true
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
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    player.play()
                }

            // Foreground Content
            VStack {
                Spacer()

                VStack(spacing: 15) {
                    Text("Sign In")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    // Email TextField
                    TextField("", text: $email)
                        .placeholder(when: email.isEmpty) {
                            Text("Email")
                                .foregroundColor(SwiftUI.Color.white.opacity(0.8))
                        }
                        .padding()
                        .background(SwiftUI.Color.white.opacity(0.2))
                        .cornerRadius(5)
                        .foregroundColor(SwiftUI.Color.white)
                        .textInputAutocapitalization(.none) // For iOS 16+


                    // Password SecureField
                    SecureField("", text: $password)
                        .placeholder(when: password.isEmpty) {
                            Text("Password")
                                .foregroundColor(SwiftUI.Color.white.opacity(0.8))
                        }
                        .padding()
                        .background(SwiftUI.Color.white.opacity(0.2))
                        .cornerRadius(5)
                        .foregroundColor(SwiftUI.Color.white)
                        .textInputAutocapitalization(.none) // For iOS 16+

                    // Sign-In Button
                    Button(action: handleSignIn) {
                        if authViewModel.isLoading {
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
                    .disabled(authViewModel.isLoading)

                    if let errorMessage = authViewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding(.top, 5)
                    }

                    // Forgot Password
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
                .background(Color.black.opacity(0.4))
                .cornerRadius(15)
                .frame(maxWidth: 350)
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
            .padding(.bottom, 50)
        }
    }

    private func handleSignIn() {
        guard isValidEmail(email) else {
            authViewModel.errorMessage = "Invalid email format."
            return
        }

        authViewModel.signIn(email: email, password: password) { success in
            if !success {
                authViewModel.errorMessage = "Failed to sign in. Check your credentials."
            }
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
