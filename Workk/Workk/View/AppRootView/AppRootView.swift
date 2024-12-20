//
//  AppRootView.swift
//  Workk
//
//  Created by Krzysztof Kogut on 28/11/2024.
//

//import SwiftUI
//
//struct AppRootView: View {
//    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
//    @State private var showMainView: Bool = false // Local state for animation
//    
//    var body: some View {
//        Group {
//            if showMainView || hasSeenOnboarding {
//                MainTabView()
////                    .transition(.move(edge: .trailing)) // Add transition animation
//            } else {
//                OnboardingView(showMainView: $showMainView)
//            }
//        }
//        .animation(.easeInOut, value: hasSeenOnboarding) // Animate the state change
//    }
//}
