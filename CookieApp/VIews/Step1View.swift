//
//  Step1View.swift
//  CookieApp
//
//  Created by Peniel Babah on 12/2/24.
//

import SwiftUI
import CoreLocation

struct Step1View: View {
    @EnvironmentObject var signUpViewModel: SignUpViewModel

    var body: some View {
        VStack(spacing: 20) {
            TextField("First Name", text: $signUpViewModel.firstName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Last Name", text: $signUpViewModel.lastName)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button(action: {
                signUpViewModel.proceedToNextStep()
            }) {
                Text("Next")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
        .alert(isPresented: $signUpViewModel.showError) {
            Alert(
                title: Text("Error"),
                message: Text(signUpViewModel.errorMessage ?? ""),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
