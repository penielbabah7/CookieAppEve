import SwiftUI

struct OrderView: View {
    @Binding var cartItems: [String: Int] // Shared cart state
    @State private var selectedBatter: String = ""
    @State private var selectedMixIns: [String] = []

    let batters = ["Chocolate Chip", "Peanut Butter", "Sugar Cookie"]
    let mixIns = [
        "Semi-Sweet Chocolate", "White Chocolate", "M&M’s", "Andes Mints",
        "Peanut Butter", "Marshmallows", "Golden Grahams", "Heath Bar Bits",
        "Oreos", "Walnuts", "Pecans", "Rainbow Sprinkles", "Caramel",
        "Pretzels", "Potato Chips", "Almond Flavoring", "Peppermint Flavoring"
    ]

    @State private var showCart = false

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Title Section
                    Text("Customize Your Cookie")
                        .font(.system(size: 34, weight: .bold))
                        .padding(.top, 20)
                        .padding(.leading)
                        .foregroundColor(.black)

                    // Batter Selection Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Choose Your Batter")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.blue)

                        ForEach(batters, id: \.self) { batter in
                            Button(action: {
                                selectedBatter = batter
                            }) {
                                HStack {
                                    Text(batter)
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(selectedBatter == batter ? .white : .black)
                                    Spacer()
                                    if selectedBatter == batter {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding()
                                .background(selectedBatter == batter ? Color.blue : Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 4)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)

                    // Mix-Ins Selection Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Choose Your Mix-Ins (Max 3)")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.blue)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(mixIns, id: \.self) { mixIn in
                                Button(action: {
                                    if selectedMixIns.contains(mixIn) {
                                        selectedMixIns.removeAll { $0 == mixIn }
                                    } else if selectedMixIns.count < 3 {
                                        selectedMixIns.append(mixIn)
                                    }
                                }) {
                                    Text(mixIn)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(selectedMixIns.contains(mixIn) ? .white : .black)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(selectedMixIns.contains(mixIn) ? Color.blue : Color.white)
                                        .cornerRadius(12)
                                        .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 4)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)

                    // Add to Cart Button
                    Button(action: {
                        let cookieName = "\(selectedBatter) with \(selectedMixIns.joined(separator: ", "))"
                        cartItems[cookieName, default: 0] += 1
                        selectedBatter = ""
                        selectedMixIns.removeAll()
                    }) {
                        Text("Add to Cart")
                            .font(.system(size: 20, weight: .semibold))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(selectedBatter.isEmpty || selectedMixIns.isEmpty ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 4)
                    }
                    .disabled(selectedBatter.isEmpty || selectedMixIns.isEmpty)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }

            // Floating Cart Button
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
        .background(Color("BackgroundColor").ignoresSafeArea())
    }
}

struct OrderView_Previews: PreviewProvider {
    static var previews: some View {
        OrderView(cartItems: .constant([:]))
    }
}
