//
//  CateringRequestView.swift
//  CookieApp
//
//  Created by Peniel Babah on 11/15/24.
//

import SwiftUI

struct CateringRequestView: View {
    @State private var fullName = ""
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var eventDate = Date()
    @State private var eventTime = Date()
    @State private var eventLocation = ""
    @State private var numberOfCookies = ""
    @State private var showConfirmation = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Request Catering")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 10)
                
                Text("Please provide the following information and we'll get back to you as soon as possible.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)
                
                // Full Name
                TextField("Full name *", text: $fullName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                // Email
                TextField("Email *", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                
                // Phone Number
                TextField("Phone number", text: $phoneNumber)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.phonePad)
                
                // Event Date and Time
                DatePicker("Event date *", selection: $eventDate, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                DatePicker("Event time *", selection: $eventTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(WheelDatePickerStyle())
                
                // Event Location
                TextField("Event location *", text: $eventLocation)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                // Number of Cookies
                TextField("Number of Cookies *", text: $numberOfCookies)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                
                // Submit Button
                Button(action: submitForm) {
                    Text("Submit")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.top, 20)
                .alert(isPresented: $showConfirmation) {
                    Alert(
                        title: Text("Catering Request Submitted"),
                        message: Text("Thank you for your inquiry! We’ll get back to you soon."),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
            .padding()
            .background(Color(red: 1.0, green: 1.0, blue: 0.8))
        }
        .navigationBarTitle("Request Catering", displayMode: .inline)
    }
    
    func submitForm() {
        // Here you would add the code to save to Firestore or send the data to your backend
        // For now, we'll just show a confirmation alert
        showConfirmation = true
    }
}

struct CateringRequestView_Previews: PreviewProvider {
    static var previews: some View {
        CateringRequestView()
    }
}
