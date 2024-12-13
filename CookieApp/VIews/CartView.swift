import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import PopupView
import Foundation

struct CartView: View {
    @Binding var cartItems: [String: Int] // A dictionary to track item names and their quantities
    var pricePerCookie: Double = 4.00

    @State private var showAlert = false
    @State private var showPaymentConfirmationPopup = false
    @State private var showPaymentAlert = false // For showing the confirmation alert
    @State private var selectedOrderId: String?
    @State private var isOrderPlaced = false
    @State private var isLoading = false
    @State private var paymentWasInitiated = false
    @State private var errorMessage: String? = nil
    @State private var pendingOrderId: String? = nil // Track pending order ID
    @Environment(\.scenePhase) var scenePhase

    private let requiredPurchases = 6 // Same value as in RewardsView
    private let paypalUsername = "DanielBaroi" // Replace with your PayPal.me username
    private let venmoUsername = "Daniel-Baroi" // Replace with your Venmo username

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                if cartItems.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "cart")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)

                        Text("Your cart is empty")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)

                        Text("Start customizing your cookie to add items!")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Cart Items Section
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Your Items")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal)

                                ForEach(cartItems.keys.sorted(), id: \.self) { cookie in
                                    HStack(spacing: 12) {
                                        Text("🍪")
                                            .font(.largeTitle)

                                        VStack(alignment: .leading) {
                                            HStack {
                                                Text(cookie)
                                                    .font(.body)
                                                    .fontWeight(.semibold)

                                                Text("(x\(cartItems[cookie] ?? 0))")
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                            }
                                            Text("$\((Double(cartItems[cookie] ?? 0) * pricePerCookie), specifier: "%.2f")")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()

                                        Button(action: {
                                            cartItems[cookie] = nil
                                        }) {
                                            Image(systemName: "trash")
                                                .foregroundColor(.red)
                                        }
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                                }
                            }

                            Divider()

                            // Total Amount Section
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Order Summary")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal)

                                HStack {
                                    Text("Total:")
                                        .font(.headline)
                                    Spacer()
                                    Text("$\(calculateTotalAmount(), specifier: "%.2f")")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.green)
                                }
                                .padding()
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(12)
                                .padding(.horizontal)
                            }

                            Divider()

                            // Payment Options Section
                            VStack(spacing: 10) {
                                Text("Payment Options")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal)

                                VStack(spacing: 10) {
                                    // Pay with PayPal
                                    Button(action: {
                                        placeOrder(paymentMethod: "PayPal") { orderId in
                                            pendingOrderId = orderId
                                            openPayPalLink(orderId: orderId)
                                        }
                                    }) {
                                        HStack {
                                            Image(systemName: "dollarsign.circle")
                                                .foregroundColor(.white)
                                            Text("Pay with PayPal")
                                                .font(.headline)
                                        }
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                    }

                                    // Pay with Venmo
                                    Button(action: {
                                        placeOrder(paymentMethod: "Venmo") { orderId in
                                            pendingOrderId = orderId
                                            openVenmoLink(orderId: orderId)
                                        }
                                    }) {
                                        HStack {
                                            Image(systemName: "dollarsign.circle")
                                                .foregroundColor(.white)
                                            Text("Pay with Venmo")
                                                .font(.headline)
                                        }
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.purple)
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Your Cart", displayMode: .inline)
            .onChange(of: scenePhase) { newPhase in
                // Observes when the app becomes active again
                if newPhase == .active && paymentWasInitiated {
                    showPaymentConfirmationPopup = true
                    paymentWasInitiated = false
                }
            }
            .overlay(
                Group {
                    if showPaymentConfirmationPopup {
                        ConfirmPaymentDialog(
                            isPresented: $showPaymentConfirmationPopup,
                            cartItems: $cartItems,
                            onConfirm: {
                                // Clear cart and navigate to HomeView
                                cartItems.removeAll()
                                navigateToHomeView()
                            },
                            onCancel: {
                                // Dismiss dialog and keep cart items
                                showPaymentConfirmationPopup = false
                            }
                        )
                    }
                }
            )
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(isOrderPlaced ? "Order Placed" : "Error"),
                message: Text(isOrderPlaced ? "Your order has been placed successfully!" : (errorMessage ?? "An unknown error occurred.")),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    // MARK: - Functions
    private func calculateTotalAmount() -> Double {
        cartItems.reduce(0) { total, item in
            total + (Double(item.value) * pricePerCookie)
        }
    }

    private func placeOrder(paymentMethod: String, completion: @escaping (String) -> Void) {
        isLoading = true
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "You must be signed in to place an order."
            showAlert = true
            isLoading = false
            return
        }

        guard !cartItems.isEmpty else {
            errorMessage = "Your cart is empty."
            showAlert = true
            isLoading = false
            return
        }

        let totalAmount = calculateTotalAmount()
        let totalCookiesInOrder = cartItems.values.reduce(0, +)

        let orderDetails: [String: Any] = [
            "userId": userId,
            "items": cartItems,
            "totalAmount": totalAmount,
            "totalCookiesInOrder": totalCookiesInOrder,
            "paymentMethod": paymentMethod,
            "paymentStatus": "pending",
            "timestamp": FieldValue.serverTimestamp()
        ]

        let db = Firestore.firestore()
        var newOrderRef: DocumentReference? = nil

        newOrderRef = db.collection("orders").addDocument(data: orderDetails) { error in
            isLoading = false
            if let error = error {
                errorMessage = "Failed to place order: \(error.localizedDescription)"
                showAlert = true
            } else if let orderId = newOrderRef?.documentID {
                completion(orderId)
            }
        }
    }

    private func openPayPalLink(orderId: String) {
        paymentWasInitiated = true
        let totalAmount = calculateTotalAmount()
        let paypalURL = "https://paypal.me/\(paypalUsername)/\(String(format: "%.2f", totalAmount))"

        if let url = URL(string: paypalURL) {
            UIApplication.shared.open(url)
        }
    }

    private func openVenmoLink(orderId: String) {
        paymentWasInitiated = true
        let totalAmount = calculateTotalAmount()
        let description = "Payment for cookies: \(cartItems.keys.joined(separator: ", "))"

        let venmoAppURL = "venmo://paycharge?txn=pay&recipients=\(venmoUsername)&amount=\(String(format: "%.2f", totalAmount))&note=\(description.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        let venmoWebFallbackURL = "https://venmo.com/u/\(venmoUsername)?txn=pay&amount=\(String(format: "%.2f", totalAmount))&note=\(description.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"

        if let url = URL(string: venmoAppURL), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else if let fallbackURL = URL(string: venmoWebFallbackURL) {
            UIApplication.shared.open(fallbackURL)
        }
    }

    private func navigateToHomeView() {
        DispatchQueue.main.async {
            UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true)
        }
    }
}

struct ConfirmPaymentDialog: View {
    @Binding var isPresented: Bool
    @Binding var cartItems: [String: Int]
    var onConfirm: () -> Void
    var onCancel: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Payment Confirmation")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)

            Text("Have you made the payment?")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            HStack(spacing: 16) {
                Button(action: {
                    onConfirm()
                    isPresented = false
                }) {
                    Text("Yes, Confirmed")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Button(action: {
                    onCancel()
                    isPresented = false
                }) {
                    Text("No, Go Back")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
        .padding()
    }
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView(cartItems: .constant(["Chocolate Chip": 2, "Peanut Butter": 1]))
    }
}
