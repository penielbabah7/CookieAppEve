import SwiftUI
import AVKit
import UIKit
import AVFoundation

struct HomeView: View {
    @Binding var selectedTab: Int
    @Binding var cartItems: [String: Int] // Shared cart state
    @State private var player: AVPlayer = {
        // Initialize the AVPlayer with looping functionality
        if let url = Bundle.main.url(forResource: "EOSC Reel", withExtension: "mp4") {
            let player = AVPlayer(url: url)
            player.isMuted = true
            player.actionAtItemEnd = .none
            NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: player.currentItem,
                queue: .main
            ) { _ in
                player.seek(to: .zero)
                player.play()
            }
            return player
        } else {
            fatalError("Video file not found!")
        }
    }()
    @State private var showAddToCartPrompt = false
    @State private var selectedCookie: String?

    var body: some View {
        VStack(spacing: 0) {
            // Video Player Section
            ZStack(alignment: .bottomLeading) {
                FullScreenVideoPlayer(player: player)
                    .frame(height: UIScreen.main.bounds.height * 0.45) // Occupies 45% of screen height
                    .clipped()

                // Extended Overlay Gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.black.opacity(0.7), Color.clear]),
                    startPoint: .bottom,
                    endPoint: .top
                )
                .frame(height: UIScreen.main.bounds.height * 0.45) // Match video height
                .ignoresSafeArea()

                // Overlay Text
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome to")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)
                        .shadow(radius: 2)
                    Text("Eve's Original Sin Cookies")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(radius: 2)
                }
                .padding()
            }
            .ignoresSafeArea()
            .onAppear {
                player.play() // Ensure video starts playing
            }

            // Cookies of the Month Section
            ZStack {
                // Background Image
                Image("Cookie Background") // Ensure this image is added to your Assets
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .opacity(0.3) // Optional: Adjust transparency for better readability

                // Content Section
                ScrollView {
                    VStack(spacing: 16) {
                        // Title Section (debug-friendly)
                        Text("Cookies of the Month")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.black) // Change to black to verify visibility
                            .padding()
                            .background(Color.yellow) // Debug: Add a bright background
                            .cornerRadius(8)
                            .padding(.top, 20)

                        // Cookie Buttons
                        ForEach(["Strawberry", "Confetti"], id: \.self) { cookieName in
                            Button(action: {
                                selectedCookie = cookieName
                                showAddToCartPrompt = true
                            }) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(cookieName)
                                            .font(.system(size: 20, weight: .semibold))
                                        Text("Cookie")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Image(systemName: "cart.badge.plus")
                                        .font(.system(size: 24))
                                        .foregroundColor(Color("AccentColor"))
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 4)
                            }
                            .alert(isPresented: $showAddToCartPrompt) {
                                Alert(
                                    title: Text("Add \(selectedCookie ?? "") to Cart?"),
                                    message: Text("Would you like to add this cookie to your cart?"),
                                    primaryButton: .default(Text("Yes")) {
                                        if let cookie = selectedCookie {
                                            cartItems[cookie, default: 0] += 1
                                        }
                                    },
                                    secondaryButton: .cancel()
                                )
                            }
                        }
                        .padding(.top, 20)

                        // View Cart Button
                        NavigationLink(destination: CartView(cartItems: $cartItems)) {
                            HStack {
                                Image(systemName: "cart")
                                    .font(.headline)
                                Text("View Cart")
                                    .font(.headline)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color("Black"))
                            .foregroundColor(.black)
                            .cornerRadius(10)
                            .shadow(color: Color("AccentColor").opacity(0.6), radius: 10, x: 0, y: 4)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct FullScreenVideoPlayer: UIViewControllerRepresentable {
    let player: AVPlayer

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspectFill // Ensures video fills the entire frame
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.player = player
        uiViewController.player?.play() // Ensure video starts playing
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(
            selectedTab: .constant(0),
            cartItems: .constant(["Strawberry": 1, "Confetti": 2])
        )
    }
}
