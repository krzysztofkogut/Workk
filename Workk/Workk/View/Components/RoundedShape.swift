//
//  RoundedShape.swift
//  Workk
//
//  Created by Krzysztof Kogut on 22/10/2023.
//

import SwiftUI

struct RoundedShape: Shape {
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: 20, height: 20))

        return Path(path.cgPath)
    }
}
