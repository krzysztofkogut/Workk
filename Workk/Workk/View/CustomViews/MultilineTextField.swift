//
//  MultilineTextField.swift
//  Workk
//
//  Created by Krzysztof Kogut on 07/09/2024.
//

import SwiftUI
import UIKit

struct MultilineTextField: UIViewRepresentable {
    var placeHolder: String
    @Binding var text: String

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.font = UIFont.latoRegular(size: 16)
        textView.text = placeHolder
        textView.textColor = UIColor.black.withAlphaComponent(0.25)
        textView.backgroundColor = .clear
        textView.isEditable = true
        textView.isScrollEnabled = true
        textView.showsHorizontalScrollIndicator = false
        textView.showsVerticalScrollIndicator = false
        textView.delegate = context.coordinator
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) { }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: MultilineTextField

        init(_ parent: MultilineTextField) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            if parent.text.isEmpty {
                textView.text = ""
            }
            
            textView.textColor = .black
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            if parent.text.isEmpty {
                textView.text = parent.placeHolder
                textView.textColor = UIColor.black.withAlphaComponent(0.25)
            }
        }
    }
}
