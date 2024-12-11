//
//  MoreOptionView.swift
//  CookieApp
//
//  Created by Peniel Babah on 11/8/24.
//
import SwiftUI

struct MoreOptionView: View {
    var title: String
    var iconName: String

    var body: some View {
        HStack {
            Image(systemName: iconName)
                .font(.title2)
                .foregroundColor(.blue)

            Text(title)
                .font(.headline)
                .foregroundColor(.primary)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.headline)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

