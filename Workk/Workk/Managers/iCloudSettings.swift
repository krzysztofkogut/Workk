//
//  iCloudSettings.swift
//  Workk
//
//  Created by Krzysztof Kogut on 11/11/2024.
//

//import SwiftUI
//import Combine
//
//class iCloudSettings: ObservableObject {
//    @Published var darkModeEnabled: Bool {
//        didSet {
//            saveToiCloud()
//        }
//    }
//
//    private let iCloudStore = NSUbiquitousKeyValueStore.default
//    private var cancellable: AnyCancellable?
//
//    init() {
//        // Load the initial value from iCloud or set a default
//        darkModeEnabled = iCloudStore.bool(forKey: "darkModeEnabled")
//
//        // Listen for changes in iCloud
//        cancellable = NotificationCenter.default.publisher(for: NSUbiquitousKeyValueStore.didChangeExternallyNotification)
//            .sink { [weak self] _ in
//                self?.loadFromiCloud()
//            }
//    }
//
//    // Save value to iCloud
//    private func saveToiCloud() {
//        iCloudStore.set(darkModeEnabled, forKey: "darkModeEnabled")
//        iCloudStore.synchronize() // Ensure the value is synced immediately
//    }
//
//    // Load value from iCloud
//    private func loadFromiCloud() {
//        darkModeEnabled = iCloudStore.bool(forKey: "darkModeEnabled")
//    }
//}

