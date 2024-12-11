//
//  OrderHistoryView.swift
//  CookieApp
//
//  Created by Peniel Babah on 11/8/24.
//
//
//  OrderHistoryView.swift
//  CookieApp
//
//  Created by Peniel Babah on 11/8/24.
//
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct OrderHistoryView: View {
    @State private var orders: [UserOrder] = []
    @State private var errorMessage: String?
    @State private var isLoading = true

    // Filtered orders
    var pendingOrders: [UserOrder] {
        orders.filter { $0.status == "Pending" }
    }

    var confirmedOrders: [UserOrder] {
        orders.filter { $0.status == "Confirmed" }
    }

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading Order History...")
                        .padding()
                } else if orders.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "cart")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)

                        Text("No Orders Found")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)

                        Text("You haven't placed any orders yet!")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Pending Orders Section
                            if !pendingOrders.isEmpty {
                                Text("Pending Orders")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.top)

                                ForEach(pendingOrders) { order in
                                    OrderRowView(order: order)
                                }
                            }

                            // Confirmed Orders Section
                            if !confirmedOrders.isEmpty {
                                Text("Confirmed Orders")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.top)

                                ForEach(confirmedOrders) { order in
                                    OrderRowView(order: order)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationBarTitle("Order History", displayMode: .inline)
            .onAppear {
                fetchOrderHistory()
            }
        }
    }

    // Fetch orders from Firestore
    private func fetchOrderHistory() {
        guard let userId = Auth.auth().currentUser?.uid else {
            self.errorMessage = "You must be signed in to view your order history."
            self.isLoading = false
            return
        }

        let db = Firestore.firestore()
        db.collection("orders")
            .whereField("userId", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                DispatchQueue.main.async {
                    self.isLoading = false
                    if let error = error {
                        self.errorMessage = "Failed to fetch orders: \(error.localizedDescription)"
                    } else if let snapshot = snapshot {
                        self.orders = snapshot.documents.compactMap { doc in
                            try? doc.data(as: UserOrder.self)
                        }
                    }
                }
            }
    }
}

// OrderRowView: A reusable view for each order row
struct OrderRowView: View {
    let order: UserOrder

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Order ID: \(order.id ?? "Unknown")")
                .font(.headline)
                .foregroundColor(.blue)

            Text("Status: \(order.status)")
                .font(.subheadline)
                .foregroundColor(order.status == "Pending" ? .orange : .green)

            Text("Total Amount: $\(order.totalAmount, specifier: "%.2f")")
                .font(.subheadline)
                .foregroundColor(.green)

            Text("Items:")
                .font(.subheadline)
                .fontWeight(.bold)

            ForEach(order.items.keys.sorted(), id: \.self) { itemName in
                Text("\(itemName) x \(order.items[itemName] ?? 0)")
                    .font(.footnote)
            }

            Text("Placed on: \(order.timestamp?.formatted() ?? "N/A")")
                .font(.footnote)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// Updated UserOrder struct
struct UserOrder: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String
    var items: [String: Int]
    var totalAmount: Double
    var status: String // New field for order status
    var timestamp: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case items
        case totalAmount
        case status
        case timestamp
    }
}
