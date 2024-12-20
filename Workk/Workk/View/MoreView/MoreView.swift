//
//  MoreView.swift
//  Workk
//
//  Created by Krzysztof Kogut on 22/10/2023.
//

import MessageUI
import Resolver
import SwiftUI

struct MoreView: View {
    @AppStorage("userTheme") private var userTheme: Theme = .systemDefault
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.colorScheme) private var scheme
    
    @ObservedObject private var viewModel: MoreViewModel = Resolver.resolve()
    
    @State private var showChangeThemeView: Bool = false
    @State private var showSubscriptionPlanView: Bool = false
    @State private var showMailView = false
    @State private var mailResult: Result<MFMailComposeResult, Error>? = nil
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.socialSectionTitle)
                    .foregroundStyle(.gray)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 4)
                
                HStack {
                    Text("Review the app")
                        .font(.latoRegular(size: 16))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.footnote)
                        .foregroundColor(.primary)
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
                .background(.whiteTheme)
                .cornerRadius(12)
                .onTapGesture {
                    viewModel.openAppStoreForReview()
                }
                                
                ShareLink(item: viewModel.shareAppMessage) {
                    HStack {
                        Text("Share the app")
                            .font(.latoRegular(size: 16))
                            .foregroundStyle(.blackTheme)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.footnote)
                            .foregroundColor(.primary)
                    }
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
                .background(.whiteTheme)
                .cornerRadius(12)
                
                HStack {
                    Text("Instagram")
                        .font(.latoRegular(size: 16))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.footnote)
                        .foregroundColor(.primary)
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
                .background(.whiteTheme)
                .cornerRadius(12)
                .onTapGesture {
                    viewModel.openInstagram()
                }
                
                HStack {
                    Text("X")
                        .font(.latoRegular(size: 16))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.footnote)
                        .foregroundColor(.primary)
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
                .background(.whiteTheme)
                .cornerRadius(12)
                .onTapGesture {
                    viewModel.openX()
                }
                
                Text(viewModel.accountSectionTitle)
                    .font(.latoBlack(size: 14))
                    .foregroundStyle(.gray)
                    .padding(.top, 32)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 4)
                
                HStack {
                    Text("Premium")
                        .font(.latoRegular(size: 16))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.footnote)
                        .foregroundColor(.primary)
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
                .background(.whiteTheme)
                .cornerRadius(12)
                .onTapGesture {
                    showSubscriptionPlanView = true
                }
                
                HStack {
                    Text("Notifications")
                        .font(.latoRegular(size: 16))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.footnote)
                        .foregroundColor(.primary)
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
                .background(.whiteTheme)
                .cornerRadius(12)
                .onTapGesture {
                    guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }
                    
                    UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                }
                
                HStack {
                    Text("Export data")
                        .font(.latoRegular(size: 16))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.footnote)
                        .foregroundColor(.primary)
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
                .background(.whiteTheme)
                .cornerRadius(12)
                .onTapGesture {
                    if let fileURL = viewModel.saveCSVToFile(context: viewContext) {
                        viewModel.exportFile(fileURL: fileURL)
                    } else {
                        print("Failed to save or export the file.")
                    }
                }
                
                HStack(spacing: 0) {
                    Text("Language")
                        .font(.latoRegular(size: 16))
                    
                    Spacer()
                    
                    Text(viewModel.getCurrentLanguageName())
                        .font(.latoBlack(size: 16))
                        .padding(.horizontal, 8)
                    
                    Image(systemName: "chevron.right")
                        .font(.footnote)
                        .foregroundColor(.primary)
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
                .background(.whiteTheme)
                .cornerRadius(12)
                .onTapGesture {
                    guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }
                    
                    UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                }
                
                HStack(spacing: 0) {
                    Text("Color Theme")
                        .font(.latoRegular(size: 16))
                    
                    Spacer()
                    
                    Text(userTheme.rawValue)
                        .font(.latoBlack(size: 16))
                        .padding(.horizontal, 8)
                    
                    Image(systemName: "chevron.right")
                        .font(.footnote)
                        .foregroundColor(.primary)
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
                .background(.whiteTheme)
                .cornerRadius(12)
                .onTapGesture {
                    showChangeThemeView = true
                }
                
                Text(viewModel.helpSectionTitle)
                    .font(.latoBlack(size: 14))
                    .foregroundStyle(.gray)
                    .padding(.top, 32)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 4)
                
                HStack {
                    Text("Contact us")
                        .font(.latoRegular(size: 16))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.footnote)
                        .foregroundColor(.primary)
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
                .background(.whiteTheme)
                .cornerRadius(12)
                .onTapGesture {
                    if MFMailComposeViewController.canSendMail() {
                        viewModel.selectedMailOption = .contactUs
                        showMailView = true
                    }
                }
                
                HStack {
                    Text("Report a bug")
                        .font(.latoRegular(size: 16))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.footnote)
                        .foregroundColor(.primary)
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
                .background(.whiteTheme)
                .cornerRadius(12)
                .onTapGesture {
                    if MFMailComposeViewController.canSendMail() {
                        viewModel.selectedMailOption = .reportBug
                        showMailView = true
                    }
                }
                
                HStack {
                    Text("Report a wrong translation")
                        .font(.latoRegular(size: 16))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.footnote)
                        .foregroundColor(.primary)
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
                .background(.whiteTheme)
                .cornerRadius(12)
                .onTapGesture {
                    if MFMailComposeViewController.canSendMail() {
                        viewModel.selectedMailOption = .reportWrongTranslation
                        showMailView = true
                    }
                }
                
                HStack {
                    Text("Sugest a new functionality")
                        .font(.latoRegular(size: 16))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.footnote)
                        .foregroundColor(.primary)
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
                .background(.whiteTheme)
                .cornerRadius(12)
                .onTapGesture {
                    if MFMailComposeViewController.canSendMail() {
                        viewModel.selectedMailOption = .suggestNewFunc
                        showMailView = true
                    }
                }
                
                Spacer()
                
                Text(viewModel.appVersionTitle)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 40)
                    .padding(.bottom, 48)
            }
            .padding(.horizontal, 16)
        }
        .padding(.top, 48)
        .overlay(alignment: .topTrailing) {
            DarkModeButton()
                .padding(.horizontal, 16)
                .padding(.top, 8)
        }
        .preferredColorScheme(userTheme.colorScheme)
        .sheet(isPresented: $showChangeThemeView) {
            ThemeChangeView(scheme: scheme)
                .presentationDetents([.height(410)])
                .presentationBackground(.clear)
        }
        .sheet(isPresented: $showMailView) {
            MailView(isShowing: $showMailView,
                     recipients: ["workkinc@gmail.com"],
                     subject: viewModel.selectedMailOption.mailTitle,
                     body: viewModel.selectedMailOption.mailBody)
        }
        .fullScreenCover(isPresented: $showSubscriptionPlanView) {
            SubscriptionPlanView()
        }
    }
}

#Preview {
    MoreView()
}
