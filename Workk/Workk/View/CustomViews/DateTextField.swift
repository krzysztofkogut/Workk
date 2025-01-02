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
                    VStack(spacing: 4) {
                        DatePicker("", selection: $date, displayedComponents: components)
                            .labelsHidden()
                            .datePickerStyle(.wheel)
                            .frame(maxWidth: .infinity)
                            .background(.whiteTheme, in: .rect(cornerRadius: 12))

                        Button {
                            isActive = false
                        } label: {
                            Text("done_title".localized)
                                .font(.latoBold(size: 18))
                                .foregroundStyle(.blackWhite)
                                .padding(.top, 16)
                                .padding(.bottom, 20)
                                .frame(maxWidth: .infinity)
                                .background(.whiteTheme, in: .rect(cornerRadius: 12))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                }
                .onTapGesture {
                    isActive = true
                }
            }
    }
}

private struct AddInputViewToTextField<Content: View>: UIViewRepresentable {
    var id: String
    var onDoneButtonTap: () -> ()

    @ViewBuilder var content: Content

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear

        DispatchQueue.main.async {
            if let window = view.window, let textField = window.allSubViews(type: UITextField.self).first(where: { $0.placeholder == id }) {
                textField.tintColor = .blackWhite

                // Convert SwiftUI View to UIKit View (for the inputView)
                let hostView = UIHostingController(rootView: content).view!
                hostView.backgroundColor = .wildSand
                hostView.frame.size = hostView.intrinsicContentSize

                // Adding custom DatePicker as the inputView
                textField.inputView = hostView

                // Refresh input views to apply changes
                textField.reloadInputViews()
            }
        }

        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

private extension UIView {
    func allSubViews<T: UIView>(type: T.Type) -> [T] {
        var resultViews = subviews.compactMap { $0 as? T }
        for view in subviews {
            resultViews.append(contentsOf: view.allSubViews(type: type))
        }
        return resultViews
    }
}

#Preview {
    @State var date = Date()

    return DateTextField(date: $date, components: [.date, .hourAndMinute]) { date in
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yy, hh:mm a"
        return formatter.string(from: date)
    }
}
