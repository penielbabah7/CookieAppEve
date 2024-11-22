//
//  FAQView.swift
//  CookieApp
//
//  Created by Peniel Babah on 11/14/24.
//

import SwiftUI

struct FAQView: View {
    var faqs: [FAQ] = [
        FAQ(question: "How soon do your cookies ship out?", answer: "Good cookies take time! All cookie orders will be processed on Saturdays and shipped before the end of Saturday. So, no matter when you order throughout the week, cookies will be shipped no sooner than Saturday of that week. Please plan accordingly!"),
        FAQ(question: "Are the cookies shipped in a cooling package?", answer: "No, cookies are not shipped in insulated cooling packaging. Cookies are put in a plastic sealed package individually, and then put into a shipping box with bubble wrap to protect the precious cargo."),
        FAQ(question: "My cookies arrived hot and melted. What should I do?", answer: "Our cookies are soft, therefore there is a possibility for cookies under extreme heat to melt and for mix-ins to get sticky. The best solution: Pop those babies into the fridge and they’ll firm right up! They might not look the prettiest in this case, but they’ll taste just as yummy! We would also advise not leaving your shipment of cookies outside in the box for too long as that’s just a recipe for messy."),
        FAQ(question: "How should my cookies be stored?", answer: "Cookies can be stored at room temperature in their packaging."),
        FAQ(question: "How long do cookies last?", answer: "Cookies have a shelf life of about 2 weeks. If ordering via shipping, they will last about a week or a week and a half. If you want those yummy treats to last longer and really savor them, you can pop them in the freezer for up to a month! Make sure that they are in their packaging or other freezer safe packaging so that they don’t get freezer burnt."),
        FAQ(question: "Is pickup an option instead of shipping?", answer: "Pickup is an option! Pickup is available on Saturdays. However, please note that this is not a drop in order type of situation. Pickup cookie orders need to be made at least a week ahead of time."),
        FAQ(question: "What do I do if I want cookies catered for an event?", answer: "First of all, that’s exciting! We would love to be a part of that special day whether it be a wedding, party, work event, or anything else! Catering orders need to be placed and planned a month ahead of the special day. We have a catering inquiry form on the website that we would love for you to fill out! Once you fill that out, we’ll call you and talk cookie business!")
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Frequently Asked Questions")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 10)
                
                ForEach(faqs) { faq in
                    VStack(alignment: .leading, spacing: 5) {
                        Text(faq.question)
                            .font(.headline)
                            .foregroundColor(.blue)
                        Text(faq.answer)
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
            }
            .padding()
        }
        .background(Color(red: 1.0, green: 1.0, blue: 0.8))
        .ignoresSafeArea()
    }
}

// Model for FAQ
struct FAQ: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
}
