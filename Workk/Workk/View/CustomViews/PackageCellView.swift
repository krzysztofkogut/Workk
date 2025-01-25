//
//  PackageCellView.swift
//  Workk
//
//  Created by Krzysztof Kogut on 12/01/2025.
//

import RevenueCat
import SwiftUI

struct PackageCellView: View {
    let package: Package
    let onSelection: (Package) async -> Void

    var body: some View {
        Button {
            Task {
                await self.onSelection(self.package)
            }
        } label: {
            self.buttonLabel
        }
        .buttonStyle(.plain)
    }

    private var buttonLabel: some View {
        VStack {
            Text(package.storeProduct.localizedTitle)
                .font(.latoBlack(size: 16))
                .foregroundStyle(.blackWhite)

            Text(package.storeProduct.localizedPricePerMonth ?? "")
                .font(.latoRegular(size: 14))
                .foregroundStyle(.gray)
            
            Text(package.storeProduct.localizedPricePerYear ?? "")
                .font(.latoRegular(size: 14))
                .foregroundStyle(.gray)

            Text(package.localizedPriceString)
                .font(.latoBold(size: 16))
                .foregroundStyle(.blackWhite)
                .padding(.top, 8)
        }
        .padding(24)
        .frame(width: 150)
        .contentShape(Rectangle())
    }
}
