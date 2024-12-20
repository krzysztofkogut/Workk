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
    var socialSectionTitle: AttributedString { get }
    var accountSectionTitle: AttributedString { get }
    var helpSectionTitle: AttributedString { get }
    var appVersionTitle: AttributedString { get }
    
    func openInstagram()
    func openFacebook()
    func openX()
    func openAppStoreForReview()
}

final class MoreViewModel: MoreViewModelProtocol {
    private let appURL = URL(string: "https://apps.apple.com/app/id1312926037")!
    private let shareMessage = "Check out this amazing app!"
    
    var selectedMailOption: MailOption = .contactUs
    
    var socialSectionTitle: AttributedString {
        var string = AttributedString("SOCIAL")
        string.kern = 3
        string.font = .latoBlack(size: 12)
        return string
    }

    var accountSectionTitle: AttributedString {
        var string = AttributedString("ACCOUNT")
        string.kern = 3
        string.font = .latoBlack(size: 12)
        return string
    }
    
    var shareAppMessage: String {
        return "Check out this amazing app: \(appURL.absoluteString)"
    }

    var helpSectionTitle: AttributedString {
        var string = AttributedString("HELP & SUPPORT")
        string.kern = 3
        string.font = .latoBlack(size: 12)
        return string
    }
    
    var appVersionTitle: AttributedString {
        var string = AttributedString("Workk v1.0.0")
        string.font = .latoBold(size: 14)
        
        if let range = string.range(of: "Workk") {
            string[range].font = .nunitoBlack(size: 14)
        }
        
        return string
    }
    
    func openInstagram() {
        let instagramURL = URL(string: "instagram://user?username=coniewiesz.kris")!
        let webURL = URL(string: "https://instagram.com/coniewiesz.kris")!
        
        if UIApplication.shared.canOpenURL(instagramURL) {
            UIApplication.shared.open(instagramURL)
        } else {
            UIApplication.shared.open(webURL)
        }
    }
    
    func openFacebook() {
        let fbAppURL = URL(string: "fb://profile/manutd")!
        let fbWebURL = URL(string: "https://facebook.com/manchesterunited")!
        
        if UIApplication.shared.canOpenURL(fbAppURL) {
            UIApplication.shared.open(fbAppURL)
        } else {
            UIApplication.shared.open(fbWebURL)
        }
    }
    
    func openX() {
        let xAppURL = URL(string: "twitter://user?screen_name=manchesterunited")!
        let xWebURL = URL(string: "https://x.com/manchesterunited")!
        
        if UIApplication.shared.canOpenURL(xAppURL) {
            UIApplication.shared.open(xAppURL)
        } else {
            UIApplication.shared.open(xWebURL)
        }
    }
    
    func openAppStoreForReview() {
        let url = URL(string: "https://apps.apple.com/app/id1312926037?action=write-review")!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    func requestReview() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
    
    func getCurrentLanguageName() -> String {
        let currentLanguageCode = Locale.preferredLanguages.first ?? "en"
        return Locale.current.localizedString(forLanguageCode: currentLanguageCode) ?? "Unknown Language"
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
            csvString += "\(id),\(jobName),\(moneyEarned),\(hourlyRate),\(startDate),\(endDate),\(isPaid),\(note),\(project),\(task)\n"
        }
        
        return csvString
    }

}
