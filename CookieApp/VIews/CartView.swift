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

    var body: some View {
           NavigationView {
               VStack {
                   if cartItems.isEmpty {
                       Text("Your cart is empty. Start customizing your cookie!")
                           .font(.headline)
                           .padding()
                   } else {
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
                                       // Remove the cookie from the cart
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

                       Text("Total: $\(cartItems.values.reduce(0) { $0 + Double($1) } * pricePerCookie, specifier: "%.2f")")
                           .font(.headline)
                           .padding()
                   }

                HStack {
                    Button(action: {
                        // Action to finalize order
                    }) {
                        Text("Order Now")
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding()
            }
            .navigationBarTitle("Your Cart", displayMode: .inline)
        }
    }
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView(cartItems: .constant(["Chocolate Chip": 2, "Peanut Butter": 1]))
    }
}
