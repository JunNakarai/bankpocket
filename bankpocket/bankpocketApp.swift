//
//  bankpocketApp.swift
//  bankpocket
//
//  Created by Jun Nakarai on 2025/09/18.
//

import SwiftUI
import SwiftData

@main
struct BankPocketApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            BankAccount.self,
            Tag.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // If model creation fails due to schema changes, try to delete and recreate
            print("ModelContainer creation failed, attempting to reset: \(error)")

            // Delete existing database files from all possible locations
            let fileManager = FileManager.default

            // Documents directory
            if let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
                let dbURL = documentsPath.appendingPathComponent("default.store")
                try? fileManager.removeItem(at: dbURL)
                try? fileManager.removeItem(at: dbURL.appendingPathExtension("wal"))
                try? fileManager.removeItem(at: dbURL.appendingPathExtension("shm"))
            }

            // Application Support directory
            if let appSupportPath = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
                let dbURL = appSupportPath.appendingPathComponent("default.store")
                try? fileManager.removeItem(at: dbURL)
                try? fileManager.removeItem(at: dbURL.appendingPathExtension("wal"))
                try? fileManager.removeItem(at: dbURL.appendingPathExtension("shm"))
            }

            do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Could not create ModelContainer after reset: \(error)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    setupDefaultTags()
                }
        }
        .modelContainer(sharedModelContainer)
    }

    // MARK: - Setup Methods

    private func setupDefaultTags() {
        Task {
            await createDefaultTagsIfNeeded()
        }
    }

    @MainActor
    private func createDefaultTagsIfNeeded() async {
        let context = sharedModelContainer.mainContext

        // Check if tags already exist
        let descriptor = FetchDescriptor<Tag>()
        do {
            let existingTags = try context.fetch(descriptor)
            if !existingTags.isEmpty {
                return // Tags already exist
            }

            // Create default tags
            for (name, color) in Tag.defaultTags {
                let tag = Tag(name: name, color: color)
                context.insert(tag)
            }

            try context.save()
        } catch {
            print("Failed to create default tags: \(error)")
        }

        // Initialize sortOrder for existing accounts if needed
        await initializeSortOrderForExistingAccounts()
    }

    @MainActor
    private func initializeSortOrderForExistingAccounts() async {
        let context = sharedModelContainer.mainContext
        let descriptor = FetchDescriptor<BankAccount>()

        do {
            let accounts = try context.fetch(descriptor)
            var needsUpdate = false

            for (index, account) in accounts.enumerated() {
                if account.sortOrder == 0 && index > 0 {
                    account.sortOrder = index
                    needsUpdate = true
                }
            }

            if needsUpdate {
                try context.save()
            }
        } catch {
            print("Failed to initialize sort order: \(error)")
        }
    }
}
