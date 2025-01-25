//
//  MoreViewModel.swift
//  Workk
//
//  Created by Krzysztof Kogut on 02/11/2024.
//

import Combine
import CoreData
import StoreKit
import SwiftUI
import UniformTypeIdentifiers

protocol MoreViewModelProtocol where Self: ObservableObject {
    var appVersion: String { get }
    var socialSectionTitle: AttributedString { get }
    var accountSectionTitle: AttributedString { get }
    var helpSectionTitle: AttributedString { get }
    var appVersionTitle: AttributedString { get }
    var applicationSectionTitle: AttributedString { get }
    
    func openInstagram()
    func openX()
    func openAppStoreForReview()
}

final class MoreViewModel: MoreViewModelProtocol {
    
    var selectedMailOption: MailOption = .contactUs

    var appVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    var socialSectionTitle: AttributedString {
        var string = AttributedString("community_title".localized.uppercased())
        string.kern = 3
        string.font = .latoBlack(size: 12)
        return string
    }

    var accountSectionTitle: AttributedString {
        var string = AttributedString("account_title".localized.uppercased())
        string.kern = 3
        string.font = .latoBlack(size: 12)
        return string
    }
    
    var applicationSectionTitle: AttributedString {
        var string = AttributedString("application_title".localized.uppercased())
        string.kern = 3
        string.font = .latoBlack(size: 12)
        return string
    }
    
    var shareAppMessage: String {
        return "check_out_app_colon_description".localized + " \(Constants.appURL.absoluteString)"
    }

    var helpSectionTitle: AttributedString {
        var string = AttributedString("help_and_support_title".localized.uppercased())
        string.kern = 3
        string.font = .latoBlack(size: 12)
        return string
    }
    
    var appVersionTitle: AttributedString {
        var string = AttributedString("workk_title".localized + " v\(appVersion)")
        string.font = .latoBold(size: 14)
        
        if let range = string.range(of: "workk_title".localized) {
            string[range].font = .nunitoBlack(size: 14)
        }
        
        return string
    }
    
    func openInstagram() {
        if UIApplication.shared.canOpenURL(Constants.instagramURL) {
            UIApplication.shared.open(Constants.instagramURL)
        } else {
            UIApplication.shared.open(Constants.instagramWebURL)
        }
    }
    
    func openX() {
        if UIApplication.shared.canOpenURL(Constants.xAppURL) {
            UIApplication.shared.open(Constants.xAppURL)
        } else {
            UIApplication.shared.open(Constants.xWebURL)
        }
    }
    
    func openAppStoreForReview() {
        if UIApplication.shared.canOpenURL(Constants.appStoreReview) {
            UIApplication.shared.open(Constants.appStoreReview)
        }
    }
    
    func requestReview() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
    
    func getCurrentLanguageName() -> String {
        let currentLanguageCode = Locale.preferredLanguages.first ?? "en"
        return Locale.current.localizedString(forLanguageCode: currentLanguageCode) ?? "unknown_language_title".localized
    }
    
    func saveCSVToFile(context: NSManagedObjectContext) -> URL? {
        let works = fetchWorksData(context: context)
        let csvString = generateCSV(from: works)
        
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        guard let documentDirectory = urls.first else { return nil }
        
        let fileURL = documentDirectory.appendingPathComponent("Works.csv")
        
        do {
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Error saving CSV file: \(error)")
            return nil
        }
    }

    func exportFile(fileURL: URL) {
        let picker = UIDocumentPickerViewController(forExporting: [fileURL])
        picker.modalPresentationStyle = .formSheet

        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = scene.windows.first?.rootViewController
        {
            rootVC.present(picker, animated: true, completion: nil)
        }
    }
    
    private func fetchWorksData(context: NSManagedObjectContext) -> [Work] {
        let fetchRequest: NSFetchRequest<Work> = Work.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching data: \(error)")
            return []
        }
    }
    
    private func generateCSV(from works: [Work]) -> String {
        var csvString = "ID,Job Name,Money Earned,Hourly Rate,Start Date,End Date,Paid,Note,Project,Task\n"
        
        for work in works {
            let id = work.id
            let jobName = work.jobName
            let moneyEarned = work.moneyEarned
            let hourlyRate = work.hourlyRate
            let startDate = work.startDate
            let endDate = work.endDate
            let isPaid = work.isPaid
            let note = work.note ?? "n/a"
            let project = work.project ?? "n/a"
            let task = work.task ?? "n/a"
            csvString += "\(String(describing: id)),\(jobName),\(moneyEarned),\(hourlyRate),\(startDate),\(endDate),\(isPaid),\(note),\(project),\(task)\n"
        }
        
        return csvString
    }

}
