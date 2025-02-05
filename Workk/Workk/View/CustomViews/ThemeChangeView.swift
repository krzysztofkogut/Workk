//
//  ThemeChangeView.swift
//  Workk
//
//  Created by Krzysztof Kogut on 26/11/2024.
//

import SwiftUI

struct ThemeChangeView: View {
    var scheme: ColorScheme
    @AppStorage("userTheme") private var userTheme: Theme = .systemDefault
    @Namespace private var animation
    
    @State private var hasAppeared = false
    @State private var circleOffset: CGSize
    
    init(scheme: ColorScheme) {
        self.scheme = scheme
        let isDark = scheme == .dark
        self._circleOffset = .init(initialValue: CGSize(width: isDark ? 30 : 150, height: isDark ? -25 : -150))
    }

    var body: some View {
        VStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 8)
                .frame(width: 40, height: 4)
                .foregroundStyle(Color.primary.opacity(0.16))
                .padding(.top, 8)
            
            Spacer()
            
            Circle()
                .fill(userTheme.color(scheme).gradient)
                .frame(width: 150, height: 150)
                .mask(
                    Rectangle()
                        .overlay {
                            Circle()
                                .offset(circleOffset)
                                .blendMode(.destinationOut)
                        }
                        .compositingGroup()
                )
            
            Text("choose_style_title".localized)
                .font(.latoBold(size: 24))
                .foregroundStyle(.blackWhite)
                .padding(.top, 24)
            
            Text("choose_style_description".localized)
                .font(.latoRegular(size: 16))
                .foregroundStyle(.blackWhite)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 0) {
                ForEach(Theme.allCases, id: \.rawValue) { theme in
                    Text(theme.title)
                        .font(.latoBold(size: 14))
                        .padding(.vertical, 10)
                        .frame(width: 100)
                        .background {
                            ZStack {
                                if userTheme == theme {
                                    Capsule()
                                        .fill(.whiteBlack)
                                        .matchedGeometryEffect(id: "activeTab", in: animation)
                                }
                            }
                            .animation(.snappy, value: userTheme)
                        }
                        .contentShape(.rect)
                        .onTapGesture {
                            userTheme = theme
                        }
                }
            }
            .padding(3)
            .background(.primary.opacity(0.06), in: .capsule)
            .padding(.vertical, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .frame(height: safeArea.bottom == .zero ? 425 : 440)
        .background(.whiteTheme)
        .clipShape(.rect(cornerRadius: 30))
        .padding(.horizontal, 15)
        .padding(.bottom, safeArea.bottom == .zero ? 15 : 0)
        .environment(\.colorScheme, scheme)
        .onAppear {
            hasAppeared = true
        }
        .onChange(of: scheme) { _, newValue in
            guard hasAppeared else { return }
            let isDark = newValue == .dark
            withAnimation(.bouncy) {
                circleOffset = CGSize(width: isDark ? 30 : 150, height: isDark ? -25 : -150)
            }
        }
    }
    
    var safeArea: UIEdgeInsets {
        if let safeArea = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.keyWindow?.safeAreaInsets {
            return safeArea
        }
        
        return .zero
    }
}

#Preview {
    ThemeChangeView(scheme: .light)
}

enum Theme: String, CaseIterable {
    case systemDefault = "Default"
    case light = "Light"
    case dark = "Dark"
    
    var colorScheme: ColorScheme? {
        switch self {
        case .systemDefault:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
    
    var title: String {
        switch self {
        case .systemDefault:
            return "default_title".localized
        case .light:
            return "light_title".localized
        case .dark:
            return "dark_title".localized
        }
    }
    
    func color(_ scheme: ColorScheme) -> Color {
        switch self {
        case .systemDefault:
            return scheme == .dark ? .athensGray : .black
        case .light:
            return .black
        case .dark:
            return .athensGray
        }
    }
    
    func backgroundColor(_ scheme: ColorScheme) -> Color {
        switch self {
        case .systemDefault:
            return scheme == .dark ? .black : .athensGray
        case .light:
           return .athensGray
        case .dark:
            return .black
        }
    }
}
