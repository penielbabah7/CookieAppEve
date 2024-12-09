import SwiftUI
import AVKit

struct OrderView: View {
    @State private var selectedBatter: String = ""
    @State private var selectedMixIns: [String] = []
    @State private var cartItems: [String: Int] = [:] // Tracks items in the cart

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

    var body: some View {
        ZStack {
            // Background Video

            // Main Content
            ScrollView {
                VStack(spacing: 30) {
                    // Title Section
                    Text("Customize Your Cookie")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 20)
                        .shadow(radius: 3)

                    // Batter Selection
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Choose Your Batter:")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.leading, 10)

                        HStack(spacing: 10) {
                            ForEach(batters, id: \.self) { batter in
                                Button(action: {
                                    selectedBatter = batter
                                }) {
                                    Text(batter)
                                        .font(.system(size: 16, weight: .semibold))
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(selectedBatter == batter ? Color.blue : Color.white.opacity(0.7))
                                        .foregroundColor(selectedBatter == batter ? .white : .black)
                                        .cornerRadius(10)
                                        .shadow(radius: 2)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Mix-In Selection
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Choose Your Mix-Ins (Max 3):")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.leading, 10)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2), spacing: 10) {
                            ForEach(mixIns, id: \.self) { mixIn in
                                Button(action: {
                                    if selectedMixIns.contains(mixIn) {
                                        selectedMixIns.removeAll { $0 == mixIn }
                                    } else if selectedMixIns.count < 3 {
                                        selectedMixIns.append(mixIn)
                                    }
                                }) {
                                    Text(mixIn)
                                        .font(.system(size: 14))
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(selectedMixIns.contains(mixIn) ? Color.green : Color.white.opacity(0.7))
                                        .foregroundColor(.black)
                                        .cornerRadius(10)
                                        .shadow(radius: 2)
                                }
                                .disabled(!selectedMixIns.contains(mixIn) && selectedMixIns.count >= 3)
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Selected Details
                    if !selectedBatter.isEmpty || !selectedMixIns.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Your Selection:")
                                .font(.headline)
                                .foregroundColor(.white)

                            if !selectedBatter.isEmpty {
                                Text("Batter: \(selectedBatter)")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                            }

                            if !selectedMixIns.isEmpty {
                                Text("Mix-Ins: \(selectedMixIns.joined(separator: ", "))")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Add to Cart Button
                    Button(action: {
                        let cookieName = "\(selectedBatter) with \(selectedMixIns.joined(separator: ", "))"
                        cartItems[cookieName, default: 0] += 1
                        selectedBatter = ""
                        selectedMixIns.removeAll()
                    }) {
                        Text("Add to Cart")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(selectedBatter.isEmpty || selectedMixIns.isEmpty ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 2)
                    }
                    .disabled(selectedBatter.isEmpty || selectedMixIns.isEmpty)
                    .padding(.horizontal)

                }
                .padding(.bottom, 50)
            }
            .background(Color.black.opacity(0.4)) // Background overlay for contrast

            // Persistent Cart Icon
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    NavigationLink(destination: CartView(cartItems: $cartItems)) {
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
    }
}

struct OrderView_Previews: PreviewProvider {
    static var previews: some View {
        OrderView()
    }
}
