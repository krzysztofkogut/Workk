//
//  View+Ext.swift
//  Workk
//
//  Created by Krzysztof Kogut on 19/10/2023.
//

import SwiftUI

extension View {
    func northWestShadow(
        color: Color = .highlight,
        radius: CGFloat = 16,
        offset: CGFloat = 6
    ) -> some View {
        return self
            .shadow(
                color: color, radius: radius, x: -offset,
                y: -offset)
            .shadow(
                color: .shadow, radius: radius, x: offset, y: offset)
    }
    
    func southEastShadow(
        color: Color = .highlight,
        radius: CGFloat = 16,
        offset: CGFloat = 6
    ) -> some View {
        return self
            .shadow(
                color: .shadow, radius: radius, x: -offset, y: -offset)
            .shadow(
                color: color, radius: radius, x: offset, y: offset)
    }
}

extension View {
    @ViewBuilder
    func rect(value: @escaping (CGRect) -> ()) -> some View {
        self
            .overlay {
                GeometryReader { geometry in
                    let rect = geometry.frame(in: .global)
                    
                    Color.clear
                        .preference(key: RectKey.self, value: rect)
                        .onPreferenceChange(RectKey.self, perform: { rect in
                            value(rect)
                        })
                }
            }
    }
    
    @ViewBuilder
    func size(value: @escaping (CGSize) -> ()) -> some View {
        self
            .background {
                GeometryReader(content: { geometry in
                    let size = geometry.size
                    
                    Color.clear
                        .preference(key: SizeKey.self, value: size)
                        .onPreferenceChange(SizeKey.self, perform: {
                            value($0)
                        })
                })
            }
    }
}

extension View {
    func readSize(_ size: Binding<CGSize>) -> some View {
        self.modifier(SizeModifier(size: size))
    }
}

extension View {
    func hide(if isHiddden: Bool) -> some View {
        ModifiedContent(content: self,
                        modifier: HideViewModifier(isHidden: isHiddden)
        )
    }
}
