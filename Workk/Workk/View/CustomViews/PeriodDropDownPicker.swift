//
//  PeriodDropDownPicker.swift
//  Workk
//
//  Created by Krzysztof Kogut on 23/04/2024.
//

import SwiftUI

struct PeriodDropDownPicker: View {
    @Binding var selection: PeriodFilter
    
    var state: DropDownPickerState = .leading
    var options: [PeriodFilter]
    var backgroundColor: Color
    var maxWidth: CGFloat = 130
    
    @SceneStorage("drop_down_zindex") private var index = 1000.0
    @State var zindex = 1000.0
    @State var showDropdown = false
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            
            VStack(alignment: state == .leading ? .leading : .trailing, spacing: 0) {
                HStack {
                    if state == .leading {
                        Text(selection.title)
                            .foregroundColor(.black)
                            .font(.latoBlack(size: 18))
                            .lineLimit(1)
                    } else {
                        Image(systemName: "chevron.down")
                            .frame(width: 20, height: 20)
                            .foregroundColor(.black)
                            .rotationEffect(.degrees((showDropdown ? -180 : 0)))
                    }
                    
                    if showDropdown {
                        Spacer()
                    }
                    
                    if state == .leading {
                        Image(systemName: "chevron.down")
                            .frame(width: 20, height: 20)
                            .foregroundColor(.black)
                            .rotationEffect(.degrees((showDropdown ? -180 : 0)))
                    } else {
                        Text(selection.title)
                            .foregroundColor(.black)
                            .font(.latoBlack(size: 18))
                            .lineLimit(1)
                    }
                }
                .padding(.horizontal, 16)
                .frame(height: 38, alignment: state == .leading ? .leading : .trailing)
                .background(backgroundColor)
                .contentShape(.rect)
                .onTapGesture {
                    index += 1
                    zindex = index
                    withAnimation(.snappy) {
                        showDropdown.toggle()
                    }
                }
                .zIndex(10)
                
                if showDropdown {
                    OptionsView()
                }
            }
            .clipped()
            .background(.white)
            .cornerRadius(6)
            .frame(height: size.height, alignment: .top)
            .offset(x: (state == .trailing && !showDropdown) ? maxWidth - (selection.title).widthOfString(usingFont: .latoBlack(size: 18)) - 60 : 0)
            
        }
        .frame(maxWidth: maxWidth, alignment: state == .leading ? .leading : .trailing)
        .frame(height: 38, alignment: state == .leading ? .leading : .trailing)
        .zIndex(zindex)
    }
    
    
    func OptionsView() -> some View {
        VStack(alignment: state == .leading ? .leading : .trailing, spacing: 0) {
            ForEach(options, id: \.rawValue) { option in
                HStack {
                    if state == .trailing {
                        Spacer()
                    }
                    
                    Text(option.title)
                        .lineLimit(1)
                    
                    if state == .leading {
                        Spacer()
                    }
                }
                .foregroundStyle(selection == option ? Color.primary : Color.gray)
                .animation(.none, value: selection)
                .frame(height: 38, alignment: state == .leading ? .leading : .trailing)
                .contentShape(.rect)
                .padding(.horizontal, 16)
                .onTapGesture {
                    withAnimation(.snappy) {
                        selection = option
                        showDropdown.toggle()
                    }
                }
            }
        }
        .background(backgroundColor)
        .transition(.move(edge: .top))
        .zIndex(1)
    }
}

#Preview {
    @State var selection: PeriodFilter = .day
    return PeriodDropDownPicker(selection: $selection, options: [.day, .week, .month, .year], backgroundColor: .wildSand)
}
