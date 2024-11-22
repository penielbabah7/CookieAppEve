//
//  NotificationBanner.swift
//  CookieApp
//
//  Created by Peniel Babah on 11/11/24.
//

import SwiftUI

struct NotificationBanner: View {
    @Binding var isVisible: Bool
    var message: String

    var body: some View {
        VStack {
            if isVisible {
                HStack {
                    Text(message)
                        .foregroundColor(.white)
                        .padding()
                    Spacer()
                    Button(action: {
                        withAnimation {
                            self.isVisible = false
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                .background(Color.blue)
                .cornerRadius(10)
                .padding()
                .transition(.move(edge: .top))
                .animation(.easeInOut)
            }
            Spacer()
        }
    }
}
