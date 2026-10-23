# Workk

Workk is an iOS app for people who track working time, jobs and earnings. It includes a work timer, a schedule, statistics, reminders, Live Activities, optional iCloud sync and subscriptions.

Built with Swift, SwiftUI, Core Data, CloudKit, ActivityKit and TipKit. Third-party packages include RevenueCat, Google Mobile Ads and Resolver; Xcode resolves the versions recorded in `Package.resolved`.

## Run locally

1. Install Xcode with an iOS SDK supporting the project (the app targets iOS 17 or later).
2. Copy `Workk/Configuration/Local.xcconfig.example` to `Workk/Configuration/Local.xcconfig`.
3. Fill in the RevenueCat SDK key, AdMob application/ad-unit identifiers, test-device identifier and Apple development team. The local file is ignored by Git. Use your own service accounts and test ad units for development.
4. Open `Workk/Workk.xcodeproj`, allow Swift packages to resolve, and select the **Workk** scheme.
5. For a different Apple developer account, configure your own bundle identifiers, CloudKit container and signing capabilities for the app and Live Activity extension.
6. Build and run on an iOS simulator or a provisioned device. Purchases, advertising and iCloud require the corresponding service setup; placeholder values are not a working configuration.

The configuration is injected into the app's Info.plist at build time. A missing local configuration stops the build; missing runtime values produce a descriptive error. Client SDK keys and ad identifiers are present in the built app and must never be treated as server credentials.

## Data

Work records are stored with Core Data. Optional iCloud synchronization uses CloudKit. Do not commit exported user records, production databases or credentials.

## License

A license has not yet been selected. This repository is not ready for public submission until its owner adds the chosen license and completes the history and build checks.
