//
//  DateTextField.swift
//  Workk
//
//  Created by Krzysztof Kogut on 03/09/2024.
//

import SwiftUI

struct DateTextField: View {
    // Config
    @Binding var date: Date
    var components: DatePickerComponents
    var formattedString: (Date) -> String
    // View Properties
    @State private var viewID: String = UUID().uuidString
    @FocusState private var isActive
    var body: some View {
        TextField(viewID, text: .constant(formattedString(date)))
            .focused($isActive)
            .overlay {
                AddInputViewToTextField(id: viewID, onDoneButtonTap: { isActive = false }) {
                    VStack(spacing: 2) {
                        DatePicker("", selection: $date, displayedComponents: components)
                            .labelsHidden()
                            .datePickerStyle(.wheel)
                            .foregroundColor(.wildSand)
                        
                        Button {
                            isActive = false
                        } label: {
                            Text("Done")
                                .font(.latoBold(size: 18))
                                .foregroundStyle(.black)
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 20)
                    }
                    .padding(.horizontal, 8)
                    .background(.wildSand, in: .rect(cornerRadius: 18))
                    .padding(.bottom, 8)
                }
                .onTapGesture {
                    isActive = true
                }
            }
    }
}

fileprivate struct AddInputViewToTextField<Content: View>: UIViewRepresentable {
    var id: String
    var onDoneButtonTap: () -> ()
    
    @ViewBuilder var content: Content

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear

        DispatchQueue.main.async {
            if let window = view.window, let textField = window.allSubViews(type: UITextField.self).first(where: { $0.placeholder == id }) {
                textField.tintColor = .white

                // Convert SwiftUI View to UIKit View (for the inputView)
                let hostView = UIHostingController(rootView: content).view!
                hostView.backgroundColor = .white
                hostView.frame.size = hostView.intrinsicContentSize

                // Adding custom DatePicker as the inputView
                textField.inputView = hostView

                // Refresh input views to apply changes
                textField.reloadInputViews()
            }
        }

        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) { }
}

fileprivate extension UIView {
    func allSubViews<T: UIView>(type: T.Type) -> [T] {
        var resultViews = subviews.compactMap({ $0 as? T })
        for view in subviews { resultViews.append(contentsOf: view.allSubViews(type: type)) }
        return resultViews
    }
}

#Preview {
    @State var date: Date = Date()
    
    return DateTextField(date: $date, components: [.date, .hourAndMinute]) { date in
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yy, hh:mm a"
        return formatter.string(from: date)
    }
}
