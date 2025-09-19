//
//  PreviewHelper.swift
//  bankpocket
//
//  Created by Jun Nakarai on 2025/09/19.
//

import SwiftUI
import SwiftData

// MARK: - Preview Helper

struct PreviewHelper {

    /// Creates a ModelContainer with sample data for previews
    @MainActor
    static func previewContainer() -> ModelContainer {
        let schema = Schema([
            BankAccount.self,
            Tag.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])

            // Add sample data
            addSampleData(to: container.mainContext)

            return container
        } catch {
            fatalError("Could not create preview ModelContainer: \(error)")
        }
    }

    /// Adds sample data to the context for previews
    private static func addSampleData(to context: ModelContext) {
        // Create sample tags
        let personalTag = Tag(name: "私", color: "#FF6B6B")
        let familyTag = Tag(name: "家族", color: "#4ECDC4")
        let workTag = Tag(name: "仕事", color: "#45B7D1")
        let savingsTag = Tag(name: "貯金", color: "#96CEB4")

        context.insert(personalTag)
        context.insert(familyTag)
        context.insert(workTag)
        context.insert(savingsTag)

        // Create sample accounts
        let account1 = BankAccount(
            bankName: "みずほ銀行",
            branchName: "渋谷支店",
            branchNumber: "123",
            accountNumber: "1234567"
        )
        account1.tags.append(contentsOf: [personalTag, familyTag])

        let account2 = BankAccount(
            bankName: "三菱UFJ銀行",
            branchName: "新宿支店",
            branchNumber: "456",
            accountNumber: "9876543"
        )
        account2.tags.append(workTag)

        let account3 = BankAccount(
            bankName: "三井住友銀行",
            branchName: "池袋支店",
            branchNumber: "789",
            accountNumber: "5555555"
        )
        account3.tags.append(contentsOf: [savingsTag, personalTag])

        context.insert(account1)
        context.insert(account2)
        context.insert(account3)

        try? context.save()
    }
}

// MARK: - Preview Extensions

extension BankAccount {
    static var preview: BankAccount {
        let account = BankAccount(
            bankName: "サンプル銀行",
            branchName: "テスト支店",
            branchNumber: "001",
            accountNumber: "1111111"
        )
        return account
    }
}

extension Tag {
    static var preview: Tag {
        Tag(name: "サンプル", color: "#FF6B6B")
    }
}