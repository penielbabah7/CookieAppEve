//
//  CartView.swift
//  CookieApp
//
//  Created by Daniel Baroi on 12/8/24.
//

import Foundation
import SwiftUI

struct CartView: View {
    @Binding var cartItems: [String: Int] // A dictionary to track item names and their quantities
    var pricePerCookie: Double = 4.00

    // State variables for customer information
    @State private var customerName: String = ""
    @State private var customerAddress: String = ""
    @State private var showAlert = false

    var body: some View {
        NavigationView {
            VStack {
                if cartItems.isEmpty {
                    Text("Your cart is empty. Start customizing your cookie!")
                        .font(.headline)
                        .padding()
                } else {
                    // List of items in the cart
                    List {
                        ForEach(cartItems.keys.sorted(), id: \.self) { cookie in
                            HStack {
                                Text(cookie)
                                Spacer()
                                Text("x \(cartItems[cookie] ?? 0)")
                                Spacer()
                                Text("$\((Double(cartItems[cookie] ?? 0) * pricePerCookie), specifier: "%.2f")")
                                Spacer()
                                Button(action: {
                                    cartItems[cookie] = nil
                                }) {
                                    Text("Remove")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .padding()

                    // Total amount
                    Text("Total: $\(cartItems.values.reduce(0) { $0 + Double($1) } * pricePerCookie, specifier: "%.2f")")
                        .font(.headline)
                        .padding()

                    // Customer Information Input
                    VStack {
                        TextField("Enter your name", text: $customerName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()

                        TextField("Enter your address", text: $customerAddress)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                    }

                    // Order Summary
                    Text("Order Summary:")
                        .font(.headline)
                        .padding(.top)

                    Text("You are paying for \(cartItems.keys.joined(separator: ", ")) cookies.")
                        .font(.subheadline)
                        .padding(.bottom)

                    // Checkout Buttons
                    HStack {
                        // Pay with PayPal
                        Button(action: {
                            if customerName.isEmpty || customerAddress.isEmpty {
                                showAlert = true
                                return
                            }

                            let totalAmount = cartItems.values.reduce(0) { $0 + Double($1) } * pricePerCookie
                            let description = "Payment for \(cartItems.keys.joined(separator: ", ")) cookies by \(customerName). Address: \(customerAddress)"
                            let paypalURL = "https://paypal.me/DanielBaroi/\(totalAmount)?note=\(description.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"

                            if let url = URL(string: paypalURL) {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Text("Pay with PayPal")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .disabled(cartItems.isEmpty)

                        // Pay with Venmo
                        Button(action: {
                            if customerName.isEmpty || customerAddress.isEmpty {
                                showAlert = true
                                return
                            }

                            let totalAmount = cartItems.values.reduce(0) { $0 + Double($1) } * pricePerCookie
                            let description = "Payment for \(cartItems.keys.joined(separator: ", ")) cookies by \(customerName). Address: \(customerAddress)"
                            let venmoURL = "https://venmo.com/u/Daniel-Baroi?txn=pay&amount=\(totalAmount)&note=\(description.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"

                            if let url = URL(string: venmoURL) {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Text("Pay with Venmo")
                                .padding()
                                .background(Color.purple)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .disabled(cartItems.isEmpty)
                    }
                    .padding()
                }
            }
            .navigationBarTitle("Your Cart", displayMode: .inline)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Missing Information"),
                    message: Text("Please enter your name and address before proceeding to payment."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView(cartItems: .constant(["Chocolate Chip": 2, "Peanut Butter": 1]))
    }
}
