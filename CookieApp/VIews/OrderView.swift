import SwiftUI
import AVKit

struct OrderView: View {
    @Binding var cartItems: [String: Int] // Shared cart state
    @State private var selectedBatter: String = ""
    @State private var selectedMixIns: [String] = []

    let batters = ["Chocolate Chip", "Peanut Butter", "Sugar Cookie"]
    let mixIns = [
        "Semi-Sweet Chocolate", "White Chocolate", "M&M’s", "Andes Mints",
        "Peanut Butter", "Marshmallows", "Golden Grahams", "Heath Bar Bits",
        "Oreos", "Walnuts", "Pecans", "Rainbow Sprinkles", "Caramel",
        "Pretzels", "Potato Chips", "Almond Flavoring", "Peppermint Flavoring",
        "Espresso", "Banana Flavoring", "Coconut", "Pineapple Flavoring",
        "Lemon Flavoring", "Strawberries", "Raspberries", "Mango Flavoring",
        "Raisins", "Blueberries", "Cinnamon", "Cinnamon and Sugar Coating",
        "Apples", "Butterscotch Chips"
    ]

    @State private var showCart = false

    var body: some View {
        ZStack {
            // Main Content
            ScrollView {
                VStack(spacing: 30) {
                    // Title Section
                    Text("Customize Your Cookie")
                        .font(.system(size: 34, weight: .bold))
                        .padding(.top, 20)

                    // Batter Selection
                    VStack(alignment: .leading) {
                        Text("Choose Your Batter:")
                            .font(.headline)

                        ForEach(batters, id: \.self) { batter in
                            Button(action: {
                                selectedBatter = batter
                            }) {
                                Text(batter)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(selectedBatter == batter ? Color.blue : Color.gray.opacity(0.3))
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                    }

                    // Mix-In Selection
                    VStack(alignment: .leading) {
                        Text("Choose Your Mix-Ins (Max 3):")
                            .font(.headline)

                        ForEach(mixIns, id: \.self) { mixIn in
                            Button(action: {
                                if selectedMixIns.contains(mixIn) {
                                    selectedMixIns.removeAll { $0 == mixIn }
                                } else if selectedMixIns.count < 3 {
                                    selectedMixIns.append(mixIn)
                                }
                            }) {
                                Text(mixIn)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(selectedMixIns.contains(mixIn) ? Color.green : Color.gray.opacity(0.3))
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                    }

                    // Add to Cart Button
                    Button(action: {
                        let cookieName = "\(selectedBatter) with \(selectedMixIns.joined(separator: ", "))"
                        cartItems[cookieName, default: 0] += 1
                        selectedBatter = ""
                        selectedMixIns.removeAll()
                    }) {
                        Text("Add to Cart")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(selectedBatter.isEmpty || selectedMixIns.isEmpty ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(selectedBatter.isEmpty || selectedMixIns.isEmpty)
                }
                .padding()
            }

            // Small Cart Icon at the Bottom-Right Corner
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        showCart = true
                    }) {
                        HStack {
                            Image(systemName: "cart")
                                .foregroundColor(.white)
                                .font(.title)
                            if !cartItems.isEmpty {
                                Text("\(cartItems.values.reduce(0, +))")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(6)
                                    .background(Color.red)
                                    .clipShape(Circle())
                            }
                        }
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(30)
                        .shadow(radius: 3)
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showCart) {
            CartView(cartItems: $cartItems)
        }
    }
}
