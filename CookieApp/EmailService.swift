//
//  Untitled.swift
//  CookieApp
//
//  Created by Peniel Babah on 12/12/24.
//

import Foundation

class EmailService {
    static let shared = EmailService()

    private init() {}

    private var sendGridAPIKey: String? {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dictionary = NSDictionary(contentsOfFile: path) as? [String: Any],
              let apiKey = dictionary["SENDGRID_API_KEY"] as? String else {
            return nil
        }
        return apiKey
    }

    func sendEmail(to recipientEmail: String, subject: String, messageBody: String, completion: @escaping (Bool, String?) -> Void) {
        guard let apiKey = sendGridAPIKey else {
            completion(false, "SendGrid API key not found.")
            return
        }

        let url = URL(string: "https://api.sendgrid.com/v3/mail/send")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "personalizations": [
                [
                    "to": [["email": recipientEmail]],
                    "subject": subject
                ]
            ],
            "from": [
                "email": "penielbabah7@gmail.com", // Verified sender email
                "name": "Eve's Original Sin Cookies"
            ],
            "content": [
                [
                    "type": "text/plain",
                    "value": messageBody
                ]
            ]
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(false, "Error sending email: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 202 {
                completion(true, nil)
            } else {
                completion(false, "Failed to send email. Response: \(String(describing: response))")
            }
        }.resume()
    }
}
