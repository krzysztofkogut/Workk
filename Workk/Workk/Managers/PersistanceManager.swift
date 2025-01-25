import CloudKit
import Combine
import CoreData

class PersistenceManager: ObservableObject {
    @Published var viewContext: NSManagedObjectContext

    static var shared = PersistenceManager(useCloud: UserDefaults.standard.bool(forKey: "iCloudSyncEnabled"))

    var container: NSPersistentContainer
    
    private let iCloudStore = NSUbiquitousKeyValueStore.default

    private var isICloudSyncEnabled: Bool {
        UserDefaults.standard.bool(forKey: "iCloudSyncEnabled")
    }

    private static let model: NSManagedObjectModel = {
        guard let url = Bundle.main.url(forResource: "Workk", withExtension: "momd") else {
            fatalError("Failed to locate Core Data model.")
        }
        guard let model = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Failed to load Core Data model.")
        }
        return model
    }()

    init(useCloud: Bool) {
        container = useCloud ? Self.makeCloudContainer() : Self.makeLocalContainer()
        viewContext = container.viewContext
    }
    
//    func toggleICloudSync(isEnabled: Bool) {
//        UserDefaults.standard.set(isEnabled, forKey: "iCloudSyncEnabled")
//        container = isICloudSyncEnabled ? Self.makeCloudContainer() : Self.makeLocalContainer()
//    }

    private static func makeCloudContainer() -> NSPersistentCloudKitContainer {
        let container = NSPersistentCloudKitContainer(name: "Workk", managedObjectModel: model)
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("No persistent store descriptions found.")
        }

        description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.Krzysztof-Kogut.Workk") // Replace with your container ID.
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Error loading CloudKit store: \(error)")
            }
        }
        return container
    }
    
    private static func makeLocalContainer() -> NSPersistentContainer {
        let container = NSPersistentContainer(name: "Workk", managedObjectModel: model)
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("No persistent store descriptions found.")
        }

        // Enable Persistent History Tracking
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.cloudKitContainerOptions = nil

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Error loading local store: \(error)")
            }
        }
        return container
    }
}
