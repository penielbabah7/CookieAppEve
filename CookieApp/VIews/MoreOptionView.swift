//
//  MoreOptionView.swift
//  CookieApp
//
//  Created by Peniel Babah on 11/8/24.
//
import SwiftUI

struct MoreOptionView: View {
    let title: String
    let iconName: String

    var body: some View {
        HStack {
            Image(systemName: iconName)
                .font(.title2)
                .foregroundColor(.black)
            Text(title)
                .font(.title2)
                .foregroundColor(.black)
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}
