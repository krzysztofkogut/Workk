//
//  OnboardingView.swift
//  Workk
//
//  Created by Krzysztof Kogut on 28/11/2024.
//

import SwiftUI

// MARK: Intro Model And Sample Intro's

struct Intro: Identifiable {
    var id: String = UUID().uuidString
    var title: String
    var description: String
}

var intros: [Intro] = [
    .init(title: "Track", description: "Add your work time and earned money \nby adding entries or using clock"),
    .init(title: "Analyze", description: "Check data on summary view \nor on stats view"),
    .init(title: "Keep data", description: "All your data will be stored in iCloud \nand shared between your Apple devices"),
]

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @Namespace var animation
    
    @State var showWalkThroughScreens: Bool = false
    @State var currentIndex: Int = 0
    @State var showHomeView: Bool = false

    var skipTitle: AttributedString {
        var string = AttributedString("SKIP")
        string.kern = 3
        string.font = .latoBlack(size: 12)
        return string
    }
    
    var welcomeDescription: AttributedString {
        var attributedString = AttributedString("Stay organised. Track your work time \nand earned money with Workk")
        attributedString.font = .latoRegular(size: 16)
        attributedString.foregroundColor = .black
 
        if let range = attributedString.range(of: "Workk") {
            attributedString[range].font = .nunitoBlack(size: 16)
            attributedString[range].foregroundColor = .black
        }
        
        return attributedString
    }
    
    var body: some View {
        ZStack {
            Color(.wildSand)
                .ignoresSafeArea()
                    
            IntroScreen()
                    
            WalkThroughScreens()
                    
            NavBar()
        }
        .animation(.interactiveSpring(response: 1.1, dampingFraction: 0.85, blendDuration: 0.85), value: showWalkThroughScreens)
        .transition(.move(edge: .leading))
    }
    
    // MARK: WalkThrough Screens

    @ViewBuilder
    func WalkThroughScreens()->some View {
        let isLast = currentIndex == intros.count
        
        GeometryReader {
            let size = $0.size
            
            ZStack {
                // MARK: Walk Through Screens

                ForEach(intros.indices, id: \.self) { index in
                    ScreenView(size: size, index: index)
                }
                
                WelcomeView(size: size, index: intros.count)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .bottom, content: {
                Indicators()
                    .opacity(isLast ? 0 : 1)
                    .animation(.easeInOut(duration: 0.35), value: isLast)
                    .offset(y: -150)
            })
            .overlay(alignment: .bottom) {
                ZStack {
                    Image(systemName: "chevron.forward")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .scaleEffect(!isLast ? 1 : 0.001)
                        .opacity(!isLast ? 1 : 0)
                    
                    Text("Continue")
                        .font(.latoBold(size: 16))
                        .foregroundColor(.white)
                        .padding(.horizontal, 15)
                        .scaleEffect(isLast ? 1 : 0.001)
                        .frame(height: isLast ? nil : 0)
                        .opacity(isLast ? 1 : 0)
                }
                .frame(width: isLast ? size.width / 2 : 55, height: isLast ? 50 : 55)
                .background {
                    RoundedRectangle(cornerRadius: 30, style: isLast ? .continuous : .circular)
                        .fill(.black)
                }
                .onTapGesture {
                    if currentIndex == intros.count {
                        // Signup Action
                        hasSeenOnboarding = true
                    } else {
                        // MARK: Updating Index

                        currentIndex += 1
                    }
                }
                .offset(y: isLast ? -40 : -60)
                // Animation
                .animation(.interactiveSpring(response: 0.9, dampingFraction: 0.8, blendDuration: 0.5), value: isLast)
            }
            .offset(y: showWalkThroughScreens ? 0 : size.height)
        }
    }
    
    // MARK: Indicator View

    // Forgot to add in the YT Video
    @ViewBuilder
    func Indicators()->some View {
        HStack(spacing: 8) {
            ForEach(intros.indices, id: \.self) { index in
                Circle()
                    .fill(.gray.opacity(0.2))
                    .frame(width: 8, height: 8)
                    .overlay {
                        if currentIndex == index {
                            Circle()
                                .fill(.black)
                                .frame(width: 8, height: 8)
                                .matchedGeometryEffect(id: "INDICATOR", in: animation)
                        }
                    }
            }
        }
        .animation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7), value: currentIndex)
    }
    
    @ViewBuilder
    func ScreenView(size: CGSize, index: Int)->some View {
        let intro = intros[index]
        
        VStack(spacing: 16) {
            Text(intro.title)
                .font(.latoBlack(size: 32))
                .offset(x: -size.width * CGFloat(currentIndex - index))

                // My Delay Starts From Top
                // You can also modify code to start delay from Bottom
                // Delay:
                // 0.2, 0.1, 0
                // Adding Extra 0.2 For Current Index
                .animation(.interactiveSpring(response: 0.9, dampingFraction: 0.8, blendDuration: 0.5).delay(currentIndex == index ? 0.2 : 0).delay(currentIndex == index ? 0.2 : 0), value: currentIndex)
            
            Text(intro.description)
                .font(.latoRegular(size: 16))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .offset(x: -size.width * CGFloat(currentIndex - index))
                .animation(.interactiveSpring(response: 0.9, dampingFraction: 0.8, blendDuration: 0.5).delay(0.1).delay(currentIndex == index ? 0.2 : 0), value: currentIndex)
        }
        .offset(y: -150)
    }
    
    // MARK: Welcome Screen

    @ViewBuilder
    func WelcomeView(size: CGSize, index: Int)->some View {
        VStack(spacing: 16) {
            Text("Welcome")
                .font(.latoBlack(size: 40))
                .offset(x: -size.width * CGFloat(currentIndex - index))
                .animation(.interactiveSpring(response: 0.9, dampingFraction: 0.8, blendDuration: 0.5).delay(0.1).delay(currentIndex == index ? 0.1 : 0), value: currentIndex)
            
            Text(welcomeDescription)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .padding(.bottom, 100)
                .offset(x: -size.width * CGFloat(currentIndex - index))
                .animation(.interactiveSpring(response: 0.9, dampingFraction: 0.8, blendDuration: 0.5).delay(currentIndex == index ? 0.2 : 0).delay(currentIndex == index ? 0.1 : 0), value: currentIndex)
        }
        .offset(y: -90)
    }
    
    // MARK: Nav Bar

    @ViewBuilder
    func NavBar()->some View {
        let isLast = currentIndex == intros.count
        
        HStack {
            Button {
                if currentIndex > 0 {
                    currentIndex -= 1
                } else {
                    showWalkThroughScreens.toggle()
                }
            } label: {
                Image(systemName: "chevron.backward")
                    .font(.title3)
                    .foregroundColor(.gray)
            }

            Spacer()
            
            Button {
                currentIndex = intros.count
            } label: {
                Text(skipTitle)
                    .foregroundStyle(.gray)
            }
            .opacity(isLast ? 0 : 1)
            .animation(.easeInOut, value: isLast)
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .frame(maxHeight: .infinity, alignment: .top)
        .offset(y: showWalkThroughScreens ? 0 : -120)
    }
    
    @ViewBuilder
    func IntroScreen()->some View {
        GeometryReader {
            let size = $0.size
            
            VStack(spacing: 10) {
                Image("workk-long-logo")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size.width / 2, height: size.height / 4)
                    .padding(.top, 160)
                                
                Text("Begin")
                    .font(.latoBold(size: 16))
                    .padding(.horizontal, 40)
                    .padding(.vertical, 14)
                    .foregroundColor(.white)
                    .background {
                        Capsule()
                            .fill(.black)
                    }
                    .onTapGesture {
                        showWalkThroughScreens.toggle()
                    }
                    .padding(.top, 340)
                    .padding(.bottom, 30)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .offset(y: showWalkThroughScreens ? -size.height : 0)
            .overlay(alignment: .bottom) {
            }
        }
        .ignoresSafeArea()
    }
}
