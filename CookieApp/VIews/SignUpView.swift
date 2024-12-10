//
//  SignUpView.swift
//  CookieApp
//
//  Created by Peniel Babah on 11/8/24.
//

import SwiftUI
import CoreLocation

struct SignUpView: View {
    @EnvironmentObject var signUpViewModel: SignUpViewModel

    var body: some View {
        VStack {
            if signUpViewModel.currentStep == 1 {
                Step1View()
            } else if signUpViewModel.currentStep == 2 {
                Step2View()
            } else if signUpViewModel.currentStep == 3 {
                Step3View()
            } else if signUpViewModel.currentStep == 4 {
                Step4View()
            }
        }
        .animation(.easeInOut, value: signUpViewModel.currentStep)
        .transition(.slide)
    }
    
    
}
