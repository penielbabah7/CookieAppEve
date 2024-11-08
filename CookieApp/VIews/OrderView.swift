//
//  OrderView.swift
//  EvesOriginalSinCookies
//
//  Created by Daniel Baroi on 10/5/24.
//

import SwiftUI
import AVKit
import UIKit
import AVFoundation

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                .foregroundColor(configuration.isOn ? .blue : .gray)
                .onTapGesture {
                    configuration.isOn.toggle()
                }
            configuration.label
        }
    }
}


struct OrderView: View {
    @State private var selectedBatter = ""
    @State private var selectedMixIns: [String] = []
    @State private var showCustomizationForm = false

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
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 20) {
                    // Order and Points section (Top)
                    HStack {
                        Text("Order")
                            .font(.system(size: 35, weight: .bold))
                            .padding(.leading)
                            .padding(.top, 40) // Adjust padding to position under the notch

                        Spacer()

                        // Placeholder for points on the top right
                        Text("1839 pts")
                            .font(.system(size: 20, weight: .bold))
                            .padding(.trailing)
                            .padding(.top, 40) // Adjust padding to position under the notch
                    }

                    // Remove the image portion here (commented out)
                    // Image("multiplecookie") // Replace with the actual image name
                    
                    // "Customize Your Perfect Cookie" section moved up
                    VStack(spacing: 20) {
                        Text("CUSTOMIZE YOUR PERFECT COOKIE!")
                            .font(.system(size: 35, weight: .bold))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)

                        // Start Baking Button
                        Button(action: {
                            showCustomizationForm.toggle()
                        }) {
                            Text("Start Baking")
                                .font(.system(size: 20, weight: .bold))
                                .frame(width: geometry.size.width * 0.8, alignment: .center)
                                .padding()
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)

                    // Show Customization Form if toggled
                    if showCustomizationForm {
                        VStack(spacing: 20) {
                            Text("Custom Cookie")
                                .font(.system(size: 25, weight: .bold))
                                .padding(.top)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()

                            // Batter Type Picker
                            VStack(alignment: .leading) {
                                Text("Batter Type")
                                    .font(.headline)
                                    .padding(.bottom, 5)
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()

                                ForEach(batters, id: \.self) { batter in
                                    Toggle(isOn: Binding(
                                        get: { selectedBatter == batter },
                                        set: { isSelected in
                                            if isSelected {
                                                selectedBatter = batter
                                            } else {
                                                selectedBatter = ""
                                            }
                                        }
                                    )) {
                                        Text(batter)
                                    }
                                    .toggleStyle(CheckboxToggleStyle()) // Custom CheckboxToggleStyle
                                    .padding(.horizontal)
                                }
                            }
                            .padding(.top)

                            // Mix-ins Selection
                            VStack(alignment: .leading) {
                                Text("Cookie Mix-ins")
                                    .font(.headline)
                                    .padding(.bottom, 5)
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()

                                ForEach(mixIns, id: \.self) { mixIn in
                                    Toggle(isOn: Binding(
                                        get: { selectedMixIns.contains(mixIn) },
                                        set: { isSelected in
                                            if isSelected {
                                                if selectedMixIns.count < 3 {
                                                    selectedMixIns.append(mixIn)
                                                }
                                            } else {
                                                selectedMixIns.removeAll { $0 == mixIn }
                                            }
                                        }
                                    )) {
                                        Text(mixIn)
                                    }
                                    .toggleStyle(CheckboxToggleStyle()) // Custom CheckboxToggleStyle
                                    .disabled(!selectedMixIns.contains(mixIn) && selectedMixIns.count >= 3)
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }

                    Spacer()
                }
                .padding(.bottom, 100) // Avoid overlap with bottom content
                .background(Color(red: 1.0, green: 1.0, blue: 0.8)) // Consistent background color
            }
            .background(Color(red: 1.0, green: 1.0, blue: 0.8))
            .ignoresSafeArea()
        }
    }
}



