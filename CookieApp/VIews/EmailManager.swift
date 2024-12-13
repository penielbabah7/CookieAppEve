//
//  EmailManager.swift
//  CookieApp
//
//  Created by Peniel Babah on 12/12/24.
//

import Foundation

class EmailManager {
    static let shared = EmailManager()

    private let sendGridAPIKey: String = {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let apiKey = plist["SENDGRID_API_KEY"] as? String else {
            fatalError("SENDGRID_API_KEY not found in Secrets.plist")
        }
        return apiKey
    }()

    func sendEmail(to recipient: String, subject: String, body: String, completion: @escaping (Bool, String?) -> Void) {
        let url = URL(string: "https://api.sendgrid.com/v3/mail/send")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(sendGridAPIKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "personalizations": [
                [
                    "to": [["email": recipient]],
                    "subject": subject
                ]
            ],
            "from": [
                "email": "penielbabah7@gmail.com", // Replace with your SendGrid verified email
                "name": "Eve's Original Sin Cookies"
            ],
            "content": [
                ["type": "text/plain", "value": body]
            ]
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(false, error.localizedDescription)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 202 else {
                let message = String(data: data ?? Data(), encoding: .utf8) ?? "Unknown error"
                completion(false, "Failed with response: \(message)")
                return
            }

            completion(true, nil)
        }

        task.resume()
    }
}
