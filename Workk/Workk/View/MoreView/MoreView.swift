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
    
    @StateObject private var viewModel: MoreViewModel = Resolver.resolve()
    @StateObject private var userSubscriptionViewModel: UserSubscriptionViewModel = Resolver.resolve()
    
    @State private var showChangeThemeView: Bool = false
    @State private var showSubscriptionPlanView: Bool = false
    @State private var showTermsAndConditions: Bool = false
    @State private var showPrivacyPolicy: Bool = false
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
                    Text("review_app_title".localized)
                        .foregroundStyle(.blackWhite)
                        .font(.latoRegular(size: 16))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.footnote)
                        .foregroundColor(.blackWhite)
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
                        Text("share_app_title".localized)
                            .foregroundStyle(.blackWhite)
                            .font(.latoRegular(size: 16))
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.footnote)
                            .foregroundColor(.blackWhite)
                    }
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
                .background(.whiteTheme)
                .cornerRadius(12)
                
                HStack {
                    Text("instagram_title".localized)
                        .foregroundStyle(.blackWhite)
                        .font(.latoRegular(size: 16))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.footnote)
                        .foregroundColor(.blackWhite)
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
                .background(.whiteTheme)
                .cornerRadius(12)
                .onTapGesture {
                    viewModel.openInstagram()
                }
                
                HStack {
                    Text("x_title".localized)
                        .foregroundStyle(.blackWhite)
                        .font(.latoRegular(size: 16))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.footnote)
                        .foregroundColor(.blackWhite)
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
                    Text("premium_title".localized)
                        .foregroundStyle(.blackWhite)
                        .font(.latoRegular(size: 16))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.footnote)
                        .foregroundColor(.blackWhite)
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
                .background(.whiteTheme)
                .cornerRadius(12)
                .onTapGesture {
                    showSubscriptionPlanView = true
                }
                
                HStack {
                    Text("notifications_title".localized)
                        .foregroundStyle(.blackWhite)
                        .font(.latoRegular(size: 16))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.footnote)
                        .foregroundColor(.blackWhite)
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
                    Text("export_data_title".localized)
                        .foregroundStyle(.blackWhite)
                        .font(.latoRegular(size: 16))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.footnote)
                        .foregroundColor(.blackWhite)
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
                .background(.whiteTheme)
                .cornerRadius(12)
                .onTapGesture {
                    guard userSubscriptionViewModel.subscriptionActive else {
                        showSubscriptionPlanView = true
                        return
                    }
                    
                    if let fileURL = viewModel.saveCSVToFile(context: viewContext) {
                        viewModel.exportFile(fileURL: fileURL)
                    } else {
                        print("Failed to save or export the file.")
                    }
                }
                
                HStack(spacing: 0) {
                    Text("language_title".localized)
                        .foregroundStyle(.blackWhite)
                        .font(.latoRegular(size: 16))
                    
                    Spacer()
                    
                    Text(viewModel.getCurrentLanguageName())
                        .foregroundStyle(.blackWhite)
                        .font(.latoBlack(size: 16))
                        .padding(.horizontal, 8)
                    
                    Image(systemName: "chevron.right")
                        .font(.footnote)
                        .foregroundColor(.blackWhite)
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
                    Text("color_theme_title".localized)
                        .foregroundStyle(.blackWhite)
                        .font(.latoRegular(size: 16))
                    
                    Spacer()
                    
                    Text(userTheme.title)
                        .foregroundStyle(.blackWhite)
                        .font(.latoBlack(size: 16))
                        .padding(.horizontal, 8)
                    
                    Image(systemName: "chevron.right")
                        .font(.footnote)
                        .foregroundColor(.blackWhite)
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
                    Text("contact_us_title".localized)
                        .foregroundStyle(.blackWhite)
                        .font(.latoRegular(size: 16))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.footnote)
                        .foregroundColor(.blackWhite)
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
                    Text("report_bug_title".localized)
                        .foregroundStyle(.blackWhite)
                        .font(.latoRegular(size: 16))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.footnote)
                        .foregroundColor(.blackWhite)
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
                    Text("report_wrong_translation_title".localized)
                        .foregroundStyle(.blackWhite)
                        .font(.latoRegular(size: 16))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.footnote)
                        .foregroundColor(.blackWhite)
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
                    Text("sugest_new_functionality_title".localized)
                        .foregroundStyle(.blackWhite)
                        .font(.latoRegular(size: 16))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.footnote)
                        .foregroundColor(.blackWhite)
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
                
                Text(viewModel.applicationSectionTitle)
                    .font(.latoBlack(size: 14))
                    .foregroundStyle(.gray)
                    .padding(.top, 32)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 4)
                
                HStack {
                    Text("privacy_policy_title".localized)
                        .foregroundStyle(.blackWhite)
                        .font(.latoRegular(size: 16))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.footnote)
                        .foregroundColor(.blackWhite)
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
                .background(.whiteTheme)
                .cornerRadius(12)
                .onTapGesture {
                    showPrivacyPolicy = true
                }
                
                HStack {
                    Text("terms_conditions_title".localized)
                        .foregroundStyle(.blackWhite)
                        .font(.latoRegular(size: 16))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.footnote)
                        .foregroundColor(.blackWhite)
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
                .background(.whiteTheme)
                .cornerRadius(12)
                .onTapGesture {
                    showTermsAndConditions = true
                }
                
                Spacer()
                
                Text(viewModel.appVersionTitle)
                    .foregroundStyle(.blackWhite)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 40)
                    .padding(.bottom, 48)
            }
            .padding(.horizontal, 16)
        }
        .padding(.top, 24)
        .sheet(isPresented: $showChangeThemeView) {
            ThemeChangeView(scheme: scheme)
                .presentationDetents([.height(440)])
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
        .fullScreenCover(isPresented: $showPrivacyPolicy) {
            SafariView(url: Constants.privacyPolicyURL)
        }
        .fullScreenCover(isPresented: $showTermsAndConditions) {
            SafariView(url: Constants.termsAndConditionsURL)
        }
    }
}

#Preview {
    MoreView()
}
