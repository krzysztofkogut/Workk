//
//  DropdownPicker.swift
//  Workk
//
//  Created by Krzysztof Kogut on 03/12/2023.
//

import SwiftUI

enum DropDownPickerState {
    case top
    case bottom
}

struct DropDownPicker: View {
    
    @Binding var selection: String?
    var hint: String
    var state: DropDownPickerState = .bottom
    var options: [String]
    var maxWidth: CGFloat = 140
    
    @State var showDropdown = false
    
    @SceneStorage("drop_down_zindex") private var index = 1000.0
    @State var zindex = 1000.0
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            
            VStack(alignment: .leading, spacing: 0) {
                
                if state == .top && showDropdown {
                    OptionsView()
                }
                
                HStack {
                    Text(selection == nil ? hint : selection!)
                        .foregroundColor(selection != nil ? .black : .gray)
                        .font(.latoBlack(size: 18))
                        .lineLimit(1)
                    
                    if showDropdown {                    
                        Spacer()
                    }
                    
                    Image(systemName: state == .top ? "chevron.up" : "chevron.down")
                        .font(.subheadline)
                        .foregroundColor(selection != nil ? .black : .gray)
                        .rotationEffect(.degrees((showDropdown ? -180 : 0)))
                }
                .padding(.horizontal, 16)
                .frame(height: 38)
                .background(.wildSand)
                .contentShape(.rect)
                .onTapGesture {
                    index += 1
                    zindex = index
                    withAnimation(.snappy) {
                        showDropdown.toggle()
                    }
                }
                .zIndex(10)
                
                if state == .bottom && showDropdown {
                    OptionsView()
                }
            }
            .clipped()
            .background(.white)
            .cornerRadius(6)
            .frame(height: size.height, alignment: state == .top ? .bottom : .top)
            
        }
        .frame(maxWidth: maxWidth)
        .frame(height: 38)
        .zIndex(zindex)
    }
    
    
    func OptionsView() -> some View {
        VStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                HStack {
                    Text(option)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Image(systemName: "checkmark")
                        .font(.subheadline)
                        .opacity(selection == option ? 1 : 0)
                }
                .foregroundStyle(selection == option ? Color.primary : Color.gray)
                .animation(.none, value: selection)
                .frame(height: 38)
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
        .background(.wildSand)
        .transition(.move(edge: state == .top ? .bottom : .top))
        .zIndex(1)
    }
}

#Preview {
    @State var selection: String? = nil
    return DropDownPicker(selection: $selection, hint: "Select", options: ["YouTube", "Instagram"])
}
