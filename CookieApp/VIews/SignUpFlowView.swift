//
//  SignUpFlowView.swift
//  CookieApp
//
//  Created by Peniel Babah on 11/22/24.
//

import SwiftUI

struct SignUpFlowView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var signUpViewModel: SignUpViewModel

    var body: some View {
        VStack {
            // Step View Display
            switch signUpViewModel.currentStep {
            case 1:
                Step1View()
                    .environmentObject(signUpViewModel)
            case 2:
                Step2View()
                    .environmentObject(signUpViewModel)
            case 3:
                Step3View()
                    .environmentObject(signUpViewModel)
            case 4:
                Step4View()
                    .environmentObject(signUpViewModel)
            default:
                Step1View()
                    .environmentObject(signUpViewModel)
            }

            // Navigation Buttons
            HStack {
                if signUpViewModel.currentStep > 1 {
                    Button("Back") {
                        signUpViewModel.currentStep -= 1
                    }
                    .padding()
                }

                Spacer()

                Button(signUpViewModel.currentStep == 4 ? "Finish" : "Next") {
                    signUpViewModel.proceedToNextStep()
                }
                .padding()
                .disabled(!signUpViewModel.canProceedToNextStep)
            }
        }
        .padding()
        .animation(.easeInOut, value: signUpViewModel.currentStep)
        .transition(.slide)
        .navigationBarTitle("Sign Up", displayMode: .inline)
    }
}
