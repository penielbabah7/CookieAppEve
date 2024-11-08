//
//  ContentView.swift
//  EvesOriginalSinCookies
//
//  Created by Daniel Baroi on 9/23/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View
    {
        ZStack
        {
            Color(red: 1.0, green: 1.0, blue: 0.8)
                .ignoresSafeArea()
            
            Image("EOSC_LOGO_MATTBLACK_transparent")
                .resizable()
                .ignoresSafeArea()
                .aspectRatio(contentMode: .fit)
                .frame(width:700, height: 600)
            
            
        }
        .padding()
        .ignoresSafeArea()
        
    }
}

#Preview {
    ContentView()
}
