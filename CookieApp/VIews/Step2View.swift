//
//  Step2View.swift
//  CookieApp
//
//  Created by Peniel Babah on 12/2/24.
//

import SwiftUI
import CoreLocation

struct Step2View: View {
    @EnvironmentObject var signUpViewModel: SignUpViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("When's your birthday?")
                .font(.title)

            DatePicker("Select Your Birthday", selection: $signUpViewModel.birthday, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()

            Button(action: {
                let age = Calendar.current.dateComponents([.year], from: signUpViewModel.birthday, to: Date()).year ?? 0
                if age >= 13 {
                    signUpViewModel.currentStep += 1
                } else {
                    signUpViewModel.errorMessage = "You must be at least 13 years old to sign up."
                }
            }) {
                Text("Next")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }

            if let errorMessage = signUpViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
        }
        .padding()
    }
}

