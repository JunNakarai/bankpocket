//
//  TagTests.swift
//  bankpocketTests
//
//  Created by Jun Nakarai on 2025/09/19.
//

import XCTest
import SwiftUI
import SwiftData
@testable import bankpocket

final class TagTests: XCTestCase {

    // MARK: - Validation Tests

    func testValidTagValidation() {
        XCTAssertNoThrow(try Tag.validate(
            name: "私",
            color: "#FF6B6B"
        ))
    }

    func testNameValidation() {
        // Empty name
        XCTAssertThrowsError(try Tag.validate(
            name: "",
            color: "#FF6B6B"
        )) { error in
            XCTAssertEqual(error as? ValidationError, .tagNameRequired)
        }

        // Too long name
        let longName = String(repeating: "a", count: 31)
        XCTAssertThrowsError(try Tag.validate(
            name: longName,
            color: "#FF6B6B"
        )) { error in
            XCTAssertEqual(error as? ValidationError, .tagNameTooLong)
        }
    }

    func testColorValidation() {
        // Invalid format - missing #
        XCTAssertThrowsError(try Tag.validate(
            name: "私",
            color: "FF6B6B"
        )) { error in
            XCTAssertEqual(error as? ValidationError, .tagColorInvalidFormat)
        }

        // Invalid format - too short
        XCTAssertThrowsError(try Tag.validate(
            name: "私",
            color: "#FF6B6"
        )) { error in
            XCTAssertEqual(error as? ValidationError, .tagColorInvalidFormat)
        }

        // Invalid format - too long
        XCTAssertThrowsError(try Tag.validate(
            name: "私",
            color: "#FF6B6BB"
        )) { error in
            XCTAssertEqual(error as? ValidationError, .tagColorInvalidFormat)
        }

        // Invalid format - invalid hex characters
        XCTAssertThrowsError(try Tag.validate(
            name: "私",
            color: "#GG6B6B"
        )) { error in
            XCTAssertEqual(error as? ValidationError, .tagColorInvalidFormat)
        }
    }

    // MARK: - Color Validation Tests

    func testValidateColor() {
        // Valid colors
        XCTAssertTrue(Tag.validateColor("#FF6B6B"))
        XCTAssertTrue(Tag.validateColor("#000000"))
        XCTAssertTrue(Tag.validateColor("#FFFFFF"))
        XCTAssertTrue(Tag.validateColor("#123ABC"))

        // Invalid colors
        XCTAssertFalse(Tag.validateColor("FF6B6B")) // Missing #
        XCTAssertFalse(Tag.validateColor("#FF6B6")) // Too short
        XCTAssertFalse(Tag.validateColor("#FF6B6BB")) // Too long
        XCTAssertFalse(Tag.validateColor("#GG6B6B")) // Invalid hex
        XCTAssertFalse(Tag.validateColor(""))
        XCTAssertFalse(Tag.validateColor("#"))
    }

    // MARK: - SwiftUI Color Tests

    func testSwiftUIColor() {
        let tag = Tag(name: "テスト", color: "#FF6B6B")
        let swiftUIColor = tag.swiftUIColor

        // Test that color is created (not nil)
        XCTAssertNotNil(swiftUIColor)
    }

    func testSortOrderDefaultsToZero() {
        let tag = Tag(name: "デフォルト", color: "#123456")

        XCTAssertEqual(tag.sortOrder, 0)
    }

    func testSortOrderInitialization() {
        let tag = Tag(name: "位置", color: "#654321", sortOrder: 5)

        XCTAssertEqual(tag.sortOrder, 5)
    }

    // MARK: - Color Extension Tests

    func testColorHexInitializer() {
        // Test through Tag's swiftUIColor property which uses Color(hex:)
        let validTag = Tag(name: "テスト", color: "#FF6B6B")
        XCTAssertNotNil(validTag.swiftUIColor)

        let invalidTag = Tag(name: "テスト", color: "#INVALID")
        // Even invalid colors should return a fallback color (blue)
        XCTAssertNotNil(invalidTag.swiftUIColor)
    }

    // MARK: - Relationship Tests

    @MainActor
    func testTagCanBeAssignedToMultipleAccounts() {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(
            for: BankAccount.self,
            Tag.self,
            AccountTagAssignment.self,
            configurations: configuration
        )
        let context = container.mainContext

        let tag = Tag(name: "共用", color: "#FF6B6B")
        let accountA = BankAccount(
            bankName: "みずほ銀行",
            branchName: "渋谷支店",
            branchNumber: "123",
            accountNumber: "1234567"
        )
        let accountB = BankAccount(
            bankName: "三井住友銀行",
            branchName: "新宿支店",
            branchNumber: "234",
            accountNumber: "2345678"
        )

        context.insert(tag)
        context.insert(accountA)
        context.insert(accountB)

        accountA.addTag(tag, in: context)
        accountB.addTag(tag, in: context)

        try? context.save()

        XCTAssertTrue(accountA.tags.contains { $0.id == tag.id })
        XCTAssertTrue(accountB.tags.contains { $0.id == tag.id })
        XCTAssertEqual(tag.accounts.count, 2)
        XCTAssertTrue(tag.accounts.contains { $0.id == accountA.id })
        XCTAssertTrue(tag.accounts.contains { $0.id == accountB.id })
    }

    @MainActor
    func testRemovingTagDoesNotAffectOtherAccounts() {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(
            for: BankAccount.self,
            Tag.self,
            AccountTagAssignment.self,
            configurations: configuration
        )
        let context = container.mainContext

        let tag = Tag(name: "共用", color: "#FF6B6B")
        let accountA = BankAccount(
            bankName: "みずほ銀行",
            branchName: "渋谷支店",
            branchNumber: "123",
            accountNumber: "1234567"
        )
        let accountB = BankAccount(
            bankName: "三井住友銀行",
            branchName: "新宿支店",
            branchNumber: "234",
            accountNumber: "2345678"
        )

        context.insert(tag)
        context.insert(accountA)
        context.insert(accountB)

        accountA.addTag(tag, in: context)
        accountB.addTag(tag, in: context)
        try? context.save()

        accountA.removeTag(tag, in: context)
        try? context.save()

        XCTAssertFalse(accountA.tags.contains { $0.id == tag.id })
        XCTAssertTrue(accountB.tags.contains { $0.id == tag.id })
        XCTAssertEqual(tag.accounts.count, 1)
        XCTAssertTrue(tag.accounts.contains { $0.id == accountB.id })
    }

    @MainActor
    func testSequentialAssignmentKeepsTagOnAllAccounts() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: BankAccount.self,
            Tag.self,
            AccountTagAssignment.self,
            configurations: configuration
        )
        let context = container.mainContext

        let sharedTag = Tag(name: "共用", color: "#FF6B6B")
        context.insert(sharedTag)

        let accounts = [
            BankAccount(
                bankName: "口座A",
                branchName: "支店A",
                branchNumber: "111",
                accountNumber: "1111111"
            ),
            BankAccount(
                bankName: "口座B",
                branchName: "支店B",
                branchNumber: "222",
                accountNumber: "2222222"
            ),
            BankAccount(
                bankName: "口座C",
                branchName: "支店C",
                branchNumber: "333",
                accountNumber: "3333333"
            )
        ]

        accounts.forEach { context.insert($0) }

        var assignedAccounts: [BankAccount] = []
        for account in accounts {
            account.updateTags([sharedTag], in: context)
            assignedAccounts.append(account)

            let expectedIDs = Set(assignedAccounts.map(\.id))
            let currentIDs = Set(sharedTag.accounts.map(\.id))
            XCTAssertEqual(currentIDs, expectedIDs, "タグ側の関連が反映されていません")

            try context.save()

            let savedIDs = Set(sharedTag.accounts.map(\.id))
            XCTAssertEqual(savedIDs, expectedIDs, "保存後にタグ関連が失われました")

            let accountID = account.id
            let reloadedDescriptor = FetchDescriptor<BankAccount>(
                predicate: #Predicate { $0.id == accountID }
            )
            guard let reloadedAccount = try context.fetch(reloadedDescriptor).first else {
                XCTFail("口座がフェッチできません: \(account.bankName)")
                return
            }

            XCTAssertTrue(
                reloadedAccount.tags.contains { $0.id == sharedTag.id },
                "保存直後の再フェッチでタグが見つかりません: \(account.bankName)"
            )
        }

        for account in accounts {
            XCTAssertTrue(
                account.tags.contains { $0.id == sharedTag.id },
                "メモリ上の口座からタグが外れています: \(account.bankName)"
            )
        }

        let fetchAccounts = try context.fetch(FetchDescriptor<BankAccount>())
        XCTAssertEqual(fetchAccounts.count, 3)
        for account in fetchAccounts {
            XCTAssertTrue(
                account.tags.contains { $0.id == sharedTag.id },
                "タグが保持されていません: \(account.bankName)"
            )
        }

        let tagID = sharedTag.id
        let tagFetch = FetchDescriptor<Tag>(
            predicate: #Predicate { $0.id == tagID }
        )
        guard let persistedTag = try context.fetch(tagFetch).first else {
            XCTFail("タグが保存されていません")
            return
        }

        XCTAssertEqual(persistedTag.accounts.count, 3)
        for account in fetchAccounts {
            XCTAssertTrue(
                persistedTag.accounts.contains { $0.id == account.id },
                "口座からタグが外れています: \(account.bankName)"
            )
        }
    }

    @MainActor
    func testTagPersistsAcrossMultipleAccountsInModelContext() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: BankAccount.self,
            Tag.self,
            AccountTagAssignment.self,
            configurations: configuration
        )
        let context = container.mainContext

        let tag = Tag(name: "共用", color: "#FF6B6B")
        context.insert(tag)

        let accountA = BankAccount(
            bankName: "みずほ銀行",
            branchName: "渋谷支店",
            branchNumber: "123",
            accountNumber: "1234567"
        )
        let accountB = BankAccount(
            bankName: "三井住友銀行",
            branchName: "新宿支店",
            branchNumber: "234",
            accountNumber: "2345678"
        )

        context.insert(accountA)
        context.insert(accountB)

        accountA.updateTags([tag], in: context)
        accountB.updateTags([tag], in: context)

        try context.save()

        let tagID = tag.id
        let tagFetch = FetchDescriptor<Tag>(
            predicate: #Predicate { $0.id == tagID }
        )
        guard let persistedTag = try context.fetch(tagFetch).first else {
            XCTFail("タグが保存されていません")
            return
        }

        XCTAssertEqual(persistedTag.accounts.count, 2)
        XCTAssertTrue(persistedTag.accounts.contains { $0.id == accountA.id })
        XCTAssertTrue(persistedTag.accounts.contains { $0.id == accountB.id })
    }

    // MARK: - Update Tests

    func testUpdate() {
        let tag = Tag(name: "テスト", color: "#FF6B6B")
        let originalUpdatedAt = tag.updatedAt

        // Wait a bit to ensure different timestamp
        Thread.sleep(forTimeInterval: 0.01)

        tag.update(name: "更新されたテスト", color: "#4ECDC4")

        XCTAssertEqual(tag.name, "更新されたテスト")
        XCTAssertEqual(tag.color, "#4ECDC4")
        XCTAssertGreaterThan(tag.updatedAt, originalUpdatedAt)
    }

    func testPartialUpdate() {
        let tag = Tag(name: "テスト", color: "#FF6B6B")
        let originalColor = tag.color

        tag.update(name: "新しい名前")

        XCTAssertEqual(tag.name, "新しい名前")
        XCTAssertEqual(tag.color, originalColor) // Unchanged
    }

    // MARK: - Default Tags Tests

    func testDefaultTags() {
        XCTAssertFalse(Tag.defaultTags.isEmpty)
        XCTAssertGreaterThanOrEqual(Tag.defaultTags.count, 4)

        // Check that all default tags have valid names and colors
        for (name, color) in Tag.defaultTags {
            XCTAssertFalse(name.isEmpty)
            XCTAssertTrue(Tag.validateColor(color))
        }

        // Check for specific expected tags
        let tagNames = Tag.defaultTags.map { $0.name }
        XCTAssertTrue(tagNames.contains("私"))
        XCTAssertTrue(tagNames.contains("家族"))
        XCTAssertTrue(tagNames.contains("仕事"))
        XCTAssertTrue(tagNames.contains("貯金"))
    }

    // MARK: - Performance Tests

    func testValidationPerformance() {
        measure {
            for _ in 0..<1000 {
                try? Tag.validate(name: "テスト", color: "#FF6B6B")
            }
        }
    }

    func testColorValidationPerformance() {
        measure {
            for _ in 0..<1000 {
                _ = Tag.validateColor("#FF6B6B")
            }
        }
    }
}
