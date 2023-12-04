//
//  MoreView.swift
//  Workk
//
//  Created by Krzysztof Kogut on 22/10/2023.
//

import SwiftUI

struct MoreView: View {
    var body: some View {
        VStack {
            ForEach(MoreViewModel.allCases, id: \.rawValue) { item in
                HStack(spacing: 16) {
                    Image(systemName: item.imageName)
                        .font(.title2)
                        .foregroundColor(.gray)
                    
                    Text(item.description)
                        .font(FontManager.subheadline)
                    
                    Spacer()
                }
            }
            .frame(height: 40)
            .padding(.horizontal)
            .padding(.vertical, 4)
            
            Spacer()
        }
        .padding(.vertical, 24)
        .padding(.top, 30)
        .overlay(alignment: .topTrailing) {
            DarkModeButton()
                .padding()
        }
    }
}

#Preview {
    MoreView()
}
