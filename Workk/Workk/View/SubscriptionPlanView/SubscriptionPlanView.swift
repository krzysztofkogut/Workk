//
//  SubscriptionPlanView.swift
//  Workk
//
//  Created by Krzysztof Kogut on 25/10/2023.
//

import SwiftUI

struct SubscriptionPlanView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan: SubscriptionPlanViewModel = .year
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "multiply.circle")
                        .foregroundColor(.black)
                        .font(.title)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 8)
            
            Spacer()
            
            ForEach(SubscriptionPlanViewModel.allCases, id: \.rawValue) { item in
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(item.title)
                            .font(FontManager.title)
                        Text(item.description)
                            .font(FontManager.body)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    
                    Spacer()
                }
                .frame(width: 300, height: selectedPlan == item ? 120 : 100)
                .background {
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .fill(.athensGray)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(selectedPlan == item ? .black : .clear, lineWidth: 2)
                }
                .onTapGesture {
                    withAnimation(.easeOut) {
                        self.selectedPlan = item
                    }
                }
            }
            
            Spacer()
        }
    }
}

#Preview {
    SubscriptionPlanView()
}
