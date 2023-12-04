//
//  CircleProgressBar.swift
//  Workk
//
//  Created by Krzysztof Kogut on 23/11/2023.
//

import SwiftUI

struct CircleProgressBar: View {
    @Binding var progress: Float
    
    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0.0, to: 1.0)
                .stroke(style: StrokeStyle(lineWidth: 8.0, lineCap: .round, lineJoin: .bevel))
                .opacity(0.3)
                .foregroundColor(Color.gray)
                .rotationEffect(.degrees(270))
            
            Circle()
                .trim(from: 0.0, to: CGFloat(self.progress))
                .stroke(style: StrokeStyle(lineWidth: 8.0, lineCap: .round, lineJoin: .bevel))
                .fill(AngularGradient(gradient: Gradient(stops: [
                    .init(color: .cranberry, location: 0.48000002),
                    .init(color: .fuchsiaBlue, location: 0.5999999),
                    .init(color: .cornflowerBlue, location: 0.7199998),
                    .init(color: .persianBlue, location: 0.8099997)]), center: .center))
                .rotationEffect(.degrees(270))
            
            VStack{
                Text("90%")
                    .font(.latoBold(size: 36))
                    .foregroundColor(.black)
                Text("of the plan")
                    .font(.latoRegular(size: 18))
                    .foregroundColor(.gray)
            }
        }
    }
}
