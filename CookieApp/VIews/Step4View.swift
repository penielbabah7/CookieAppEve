//
//  Step4View.swift
//  CookieApp
//
//  Created by Peniel Babah on 12/2/24.
//
import SwiftUI
import CoreLocation

struct Step4View: View {
    @EnvironmentObject var signUpViewModel: SignUpViewModel
    @ObservedObject var addressHelper = AddressSearchHelper()

    var body: some View {
        VStack(spacing: 20) {
            Text("Where do you live?")
                .font(.title)

            TextField("Address", text: $addressHelper.queryFragment)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            if !addressHelper.suggestions.isEmpty {
                List(addressHelper.suggestions) { suggestion in
                    Button(action: {
                        signUpViewModel.address = suggestion.title
                        signUpViewModel.city = suggestion.subtitle
                        signUpViewModel.currentStep += 1
                    }) {
                        VStack(alignment: .leading) {
                            Text(suggestion.title)
                            Text(suggestion.subtitle)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }

            if let errorMessage = signUpViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
        }
        .padding()
    }
}
