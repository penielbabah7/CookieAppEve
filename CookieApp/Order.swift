//
//  Order.swift
//  CookieApp
//
//  Created by Daniel Baroi on 12/9/24.
//

import Foundation
import SwiftUI

struct Order: Codable, Identifiable {
    let id: UUID
    let customerName: String
    let customerAddress: String
    let items: [String: Int]
    let totalAmount: Double
    let date: Date
}

class OrderManager: ObservableObject {
    @Published var orders: [Order] = []

    private let ordersKey = "orders"

    init() {
        loadOrders()
    }

    func addOrder(_ order: Order) {
        orders.append(order)
        saveOrders()
    }

    private func saveOrders() {
        if let encoded = try? JSONEncoder().encode(orders) {
            UserDefaults.standard.set(encoded, forKey: ordersKey)
        }
    }

    private func loadOrders() {
        if let data = UserDefaults.standard.data(forKey: ordersKey),
           let decoded = try? JSONDecoder().decode([Order].self, from: data) {
            orders = decoded
        }
    }
}
