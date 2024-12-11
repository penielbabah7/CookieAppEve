import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct CartView: View {
    @Binding var cartItems: [String: Int] // A dictionary to track item names and their quantities
    var pricePerCookie: Double = 4.00

    @State private var showAlert = false
    @State private var isOrderPlaced = false
    @State private var errorMessage: String? = nil
    @State private var pendingOrderId: String? = nil // Track pending order ID

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
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "You must be signed in to place an order."
            showAlert = true
            return
        }

        // Calculate total amount and total cookies in the cart
        let totalAmount = calculateTotalAmount()
        let totalCookiesInOrder = cartItems.values.reduce(0, +) // Sum up all cookie quantities in the cart

        // Prepare the order details
        let orderDetails: [String: Any] = [
            "userId": userId,
            "items": cartItems,
            "totalAmount": totalAmount,
            "totalCookiesInOrder": totalCookiesInOrder,
            "paymentMethod": paymentMethod,
            "paymentStatus": "pending", // Default status as "pending"
            "timestamp": FieldValue.serverTimestamp()
        ]

        // Reference to Firestore database
        let db = Firestore.firestore()
        var newOrderRef: DocumentReference? = nil

        // Add the order to Firestore
        newOrderRef = db.collection("orders").addDocument(data: orderDetails) { error in
            if let error = error {
                // Handle Firestore error
                errorMessage = "Failed to place order: \(error.localizedDescription)"
                showAlert = true
            } else if let orderId = newOrderRef?.documentID {
                // If the order was successfully created
                print("Order successfully created with ID: \(orderId)")

                // Update the user's total cookies bought for rewards
                db.collection("users").document(userId).updateData([
                    "totalCookiesBought": FieldValue.increment(Int64(totalCookiesInOrder))
                ]) { error in
                    if let error = error {
                        print("Failed to update total cookies bought: \(error.localizedDescription)")
                    } else {
                        print("Successfully updated total cookies bought!")
                    }
                }

                // Pass the orderId back for payment processing
                completion(orderId)
            }
        }
    }


    private func openPayPalLink(orderId: String) {
        let totalAmount = calculateTotalAmount()
        let paypalURL = "https://paypal.me/\(paypalUsername)/\(String(format: "%.2f", totalAmount))"
        
        if let url = URL(string: paypalURL) {
            UIApplication.shared.open(url) { success in
                if success {
                    // Prompt user to confirm payment manually
                }
            }
        }
    }


    private func openVenmoLink(orderId: String) {
        let totalAmount = calculateTotalAmount()
        let description = "Payment for cookies: \(cartItems.keys.joined(separator: ", "))"

        let venmoAppURL = "venmo://paycharge?txn=pay&recipients=\(venmoUsername)&amount=\(String(format: "%.2f", totalAmount))&note=\(description.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        let venmoWebFallbackURL = "https://venmo.com/u/\(venmoUsername)?txn=pay&amount=\(String(format: "%.2f", totalAmount))&note=\(description.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"

        if let url = URL(string: venmoAppURL), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url) { success in
                if success {
                    confirmPayment(orderId: orderId) { success, error in
                        if success {
                            print("Payment confirmed successfully for order: \(orderId)")
                        } else {
                            print("Failed to confirm payment for order: \(orderId). Error: \(error ?? "Unknown error")")
                        }
                    }
                }
            }
        } else if let fallbackURL = URL(string: venmoWebFallbackURL) {
            UIApplication.shared.open(fallbackURL)
        }
    }


    private func confirmPayment(orderId: String, completion: @escaping (Bool, String?) -> Void) {
        let db = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(false, "No user ID found.")
            return
        }

        // Step 1: Update the order's payment status
        db.collection("orders").document(orderId).updateData([
            "paymentStatus": "confirmed"
        ]) { error in
            if let error = error {
                print("Failed to confirm payment: \(error.localizedDescription)")
                completion(false, "Failed to confirm payment: \(error.localizedDescription)")
                return
            }
            print("Payment confirmed successfully for order ID: \(orderId)")

            // Step 2: Increment the user's purchase count
            let userRef = db.collection("users").document(userId)
            userRef.updateData([
                "purchaseCount": FieldValue.increment(Int64(1))
            ]) { error in
                if let error = error {
                    print("Failed to update purchase count: \(error.localizedDescription)")
                    completion(false, "Failed to update purchase count: \(error.localizedDescription)")
                    return
                }
                print("Purchase count updated successfully.")

                // Step 3: Fetch order details and notify the manager
                db.collection("orders").document(orderId).getDocument { document, error in
                    if let error = error {
                        print("Failed to fetch order details: \(error.localizedDescription)")
                        completion(false, "Failed to fetch order details: \(error.localizedDescription)")
                        return
                    }

                    guard let document = document, document.exists, let orderData = document.data() else {
                        completion(false, "Order details not found.")
                        return
                    }

                    // Notify the manager
                    sendOrderNotification(orderDetails: orderData) { success, notificationError in
                        if let notificationError = notificationError {
                            print("Failed to notify manager: \(notificationError)")
                        } else {
                            print("Manager notified successfully.")
                        }

                        // Step 4: Clear the cart only after all steps succeed
                        DispatchQueue.main.async {
                            cartItems.removeAll()
                        }

                        // Final completion
                        completion(true, nil)
                    }
                }
            }
        }
    }

    // Function to send a notification to the manager
    private func sendOrderNotification(orderDetails: [String: Any], completion: @escaping (Bool, String?) -> Void) {
        guard let email = orderDetails["userEmail"] as? String,
              let items = orderDetails["items"] as? [String: Int],
              let totalAmount = orderDetails["totalAmount"] as? Double else {
            completion(false, "Invalid order details.")
            return
        }

        let subject = "Order Confirmation: \(email)"
        let messageBody = """
        A new order has been confirmed.
        
        Order Details:
        - User Email: \(email)
        - Items: \(items.map { "\($0.key) x \($0.value)" }.joined(separator: ", "))
        - Total Amount: $\(String(format: "%.2f", totalAmount))

        Please process this order at your earliest convenience.
        """

        // Replace with actual email-sending code (e.g., using an email API)
        print("Sending email to manager...")
        print("Subject: \(subject)")
        print("Body: \(messageBody)")

        // Simulating email sending success
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            completion(true, nil)
        }
    }


}


struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView(cartItems: .constant(["Chocolate Chip": 2, "Peanut Butter": 1]))
    }
}
