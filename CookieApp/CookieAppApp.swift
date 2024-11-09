//
//  EvesOriginalSinCookiesApp.swift
//  EvesOriginalSinCookies
//
//  Created by Daniel Baroi on 9/23/24.
//

import SwiftUI
import AVKit
import UIKit
import AVFoundation

struct YourApp: App {
    init() {
        // Customize Tab Bar appearance
        let appearance = UITabBarAppearance()
        
        // Set background color
        appearance.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 0.8, alpha: 1.0) // Your pastel yellow or tan color
        
        // Remove separator line by setting shadow color and shadow image to nil
        appearance.shadowColor = .clear
        appearance.shadowImage = nil

        // Apply appearance settings
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some Scene {
        WindowGroup {
            MenuView()
        }
    }
}
