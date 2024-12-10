import SwiftUI

struct Step4View: View {
    @EnvironmentObject var signUpViewModel: SignUpViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("Complete Your Address")
                .font(.title)
                .bold()

            TextField("Street Address", text: $signUpViewModel.address)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            TextField("City", text: $signUpViewModel.city)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            TextField("State", text: $signUpViewModel.state)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            TextField("Zip Code", text: $signUpViewModel.zipCode)
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                signUpViewModel.proceedToNextStep()
            }) {
                Text("Finish")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(signUpViewModel.canProceedToNextStep ? Color.green : Color.gray)
                    .cornerRadius(10)
            }
            .disabled(!signUpViewModel.canProceedToNextStep)

            if let errorMessage = signUpViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            Spacer()
        }
        .padding()
    }
}
