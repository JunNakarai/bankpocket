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
            fatalError("Could not create ModelContainer: \(error)")
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
    }
}
