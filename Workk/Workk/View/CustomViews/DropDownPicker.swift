//
//  DropDownPicker.swift
//  Workk
//
//  Created by Krzysztof Kogut on 03/12/2023.
//

import SwiftUI

enum DropDownPickerState {
    case leading
    case trailing
}

struct DropDownPicker: View {
    @Binding var selection: String?
    @Binding var addNewOption: Bool
    
    var hint: String
    var state: DropDownPickerState = .leading
    var options: [String]
    var hideAddNewOption: Bool = false
    var backgroundColor: Color
    var maxWidth: CGFloat = 130
    
    @SceneStorage("drop_down_zindex") private var index = 2000.0
    @State var zindex = 2000.0
    @State var showDropdown = false
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            
            VStack(alignment: state == .leading ? .leading : .trailing, spacing: 0) {
                HStack {
                    if state == .leading {
                        Text(selection == nil ? hint : selection!)
                            .foregroundColor(selection != nil ? .black : .gray)
                            .font(.latoBlack(size: 18))
                            .lineLimit(1)
                    } else {
                        Image(systemName: "chevron.down")
                            .frame(width: 20, height: 20)
                            .foregroundColor(selection != nil ? .black : .gray)
                            .rotationEffect(.degrees(showDropdown ? -180 : 0))
                    }
                    
                    if showDropdown {
                        Spacer()
                    }
                    
                    if state == .leading {
                        Image(systemName: "chevron.down")
                            .frame(width: 20, height: 20)
                            .foregroundColor(selection != nil ? .black : .gray)
                            .rotationEffect(.degrees(showDropdown ? -180 : 0))
                    } else {
                        Text(selection == nil ? hint : selection!)
                            .foregroundColor(selection != nil ? .black : .gray)
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
            .offset(x: (state == .trailing && !showDropdown) ? maxWidth - (selection == nil ? hint : selection!).widthOfString(usingFont: .latoBlack(size: 18)) - 60 : 0)
        }
        .frame(maxWidth: maxWidth, alignment: state == .leading ? .leading : .trailing)
        .frame(height: 38, alignment: state == .leading ? .leading : .trailing)
        .onAppear {
            showDropdown = false
        }
        .zIndex(zindex)
    }
    
    func OptionsView() -> some View {
        VStack(alignment: state == .leading ? .leading : .trailing, spacing: 0) {
            ScrollViewReader { proxy in
                if options.count > 2 {
                    ScrollView {
                        ForEach(options.indices, id: \.self) { index in
                            let option = options[index]
                            
                            HStack {
                                if state == .trailing {
                                    Spacer()
                                }
                                
                                Text(option)
                                    .lineLimit(1)
                                
                                if state == .leading {
                                    Spacer()
                                }
                            }
                            .foregroundStyle(selection == option ? Color.primary : Color.gray)
                            .animation(.none, value: selection)
                            .frame(height: 38, alignment: state == .leading ? .leading : .trailing)
                            .contentShape(Rectangle())
                            .padding(.horizontal, 16)
                            .onTapGesture {
                                withAnimation(.snappy) {
                                    selection = option
                                    showDropdown.toggle()
                                }
                            }
                            .id(index) // Set each item’s index as its ID
                        }
                    }
                    .frame(height: 92)
                } else {
                    ForEach(options.indices, id: \.self) { index in
                        let option = options[index]
                        
                        HStack {
                            if state == .trailing {
                                Spacer()
                            }
                            
                            Text(option)
                                .lineLimit(1)
                            
                            if state == .leading {
                                Spacer()
                            }
                        }
                        .foregroundStyle(selection == option ? Color.primary : Color.gray)
                        .animation(.none, value: selection)
                        .frame(height: 38, alignment: state == .leading ? .leading : .trailing)
                        .contentShape(Rectangle())
                        .padding(.horizontal, 16)
                        .onTapGesture {
                            withAnimation(.snappy) {
                                selection = option
                                showDropdown.toggle()
                            }
                        }
                        .id(index) // Use index-based ID for each item
                    }
                }
                
                if !hideAddNewOption {
                    HStack {
                        Image(systemName: "plus")
                            .font(.body)
                        
                        Spacer()
                        
                        if options.count > 2 {
                            Button {
                                withAnimation {
                                    // Scroll to the last element using its index-based ID
                                    proxy.scrollTo(options.count - 1, anchor: .bottom)
                                }
                            } label: {
                                Image(systemName: "chevron.down.circle.fill")
                                    .font(.body)
                                    .foregroundColor(.black)
                            }
                        }
                    }
                    .animation(.none, value: selection)
                    .frame(height: 38, alignment: state == .leading ? .leading : .trailing)
                    .background(backgroundColor)
                    .contentShape(Rectangle())
                    .padding(.horizontal, 16)
                    .onTapGesture {
                        withAnimation(.snappy) {
                            addNewOption.toggle()
                            showDropdown.toggle()
                        }
                    }
                }
            }
        }
        .background(backgroundColor)
    }
}

#Preview {
    @State var selection: String? = nil
    @State var addNewOption = false
    return DropDownPicker(selection: $selection, addNewOption: $addNewOption, hint: "Select", state: .trailing, options: ["YouTube", "Instagram", "Facebook", "Twitter"], backgroundColor: .wildSand)
}
