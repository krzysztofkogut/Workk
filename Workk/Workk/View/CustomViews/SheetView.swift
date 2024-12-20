//
//  SheetView.swift
//  Workk
//
//  Created by Krzysztof Kogut on 08/11/2024.
//

import SwiftUI

/// Sample View
struct SheetView: View {
    var title: String
    var content: String
    var button1: Config
    var button2: Config?
    var body: some View {
        VStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 8)
                .frame(width: 40, height: 4)
                .foregroundStyle(Color.primary.opacity(0.16))
                .padding(.top, 8)
            
            Text(title)
                .font(.latoBold(size: 24))
                .padding(.top, 8)
            
            Text(content)
                .font(.latoRegular(size: 16))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding(.bottom, 24)
            
            ButtonView(button1)
                .padding(.bottom, 8)
            
            if let button2 {
                ButtonView(button2)
                    .padding(.top, -6)
            }
        }
        .frame(maxWidth: .infinity)
        .padding([.horizontal, .bottom], 15)
        .background {
            RoundedRectangle(cornerRadius: 15)
                .fill(.background)
        }
        .shadow(color: .black.opacity(0.12), radius: 8)
        .padding(.horizontal, 15)
    }
    
    @ViewBuilder
    func ButtonView(_ config: Config) -> some View {
        Button {
            config.action()
        } label: {
            Text(config.content)
                .font(.latoBold(size: 16))
                .foregroundStyle(config.foreground)
                .frame(width: 120, height: 44)
                .background(config.tint, in: .rect(cornerRadius: 24))
        }
    }
    
    struct Config {
        var content: String
        var tint: Color
        var foreground: Color
        var action: () -> () = {  }
    }
}
