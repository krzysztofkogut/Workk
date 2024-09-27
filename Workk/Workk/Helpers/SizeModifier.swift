//
//  SizeModifier.swift
//  Workk
//
//  Created by Krzysztof Kogut on 14/09/2024.
//
import SwiftUI

struct SizeModifier: ViewModifier {
    @Binding var size: CGSize
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            self.size = geometry.size
                        }
                        .onChange(of: geometry.size) { newSize in
                            self.size = newSize
                        }
                }
            )
    }
}
