//
//  ChipsView.swift
//  Workk
//
//  Created by Krzysztof Kogut on 15/02/2025.
//

import SwiftUI

extension String {
    func size(using font: UIFont) -> CGSize {
        let attributes = [NSAttributedString.Key.font: font]
        return self.size(withAttributes: attributes)
    }
}

struct ChipsView<Content: View>: View {
    var fix3Count: Bool = false
    var containerWidth: CGFloat
    var chips: [Chip]
    @ViewBuilder var content: (Chip) -> Content

    var body: some View {
        let chunkedCollection = fix3Count ? chips.chunked(3) : chips.chunkByWidth(containerWidth)
        
        VStack(alignment: .center, spacing: 10) {
            ForEach(chunkedCollection.indices, id: \.self) { index in
                HStack(spacing: 10) {
                    ForEach(chunkedCollection[index]) { chip in
                        content(chip)
                    }
                }
            }
        }
    }
}

struct Chip: Identifiable {
    let id: UUID = UUID()
    let dayNumber: Int
    let name: String
}

extension Array where Element == Chip {
    func chunkByWidth(_ containerWidth: CGFloat) -> [[Chip]] {
        var row: [Chip] = []
        var rowWidth: CGFloat = 0
        var rows: [[Chip]] = []
        let spacing: CGFloat = 10

        for chip in self {
            let chipWidth = chip.name.size(using: .latoBold(size: 12)).width + 20 + spacing

            if rowWidth + chipWidth < containerWidth {
                row.append(chip)
                rowWidth += chipWidth
            } else {
                rows.append(row)
                row = [chip]
                rowWidth = chipWidth
            }
        }

        if !row.isEmpty {
            rows.append(row)
        }

        return rows
    }

    func chunked(_ size: Int) -> [[Chip]] {
        stride(from: 0, to: count, by: size).map { index in
            Array(self[index..<Swift.min(index + size, count)])
        }
    }
}
