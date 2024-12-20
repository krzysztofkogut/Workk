//
//  FilterOptionView.swift
//  Workk
//
//  Created by Krzysztof Kogut on 15/11/2024.
//

import SwiftUI

struct FilterOptionView: View {
    var title: String
    @Binding var isSelected: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .font(.latoRegular(size: 16))
            
            Spacer()
            
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .background(.white)
        .cornerRadius(12)
    }
}
