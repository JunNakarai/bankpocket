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

// MARK: - Validation

final class TagValidationTests: XCTestCase {

    func testValidTagValidation() {
        XCTAssertNoThrow(try Tag.validate(
            name: "私",
            color: "#FF6B6B"
        ))
    }

    func testNameValidation() {
        XCTAssertThrowsError(try Tag.validate(
            name: "",
            color: "#FF6B6B"
        )) { error in
            XCTAssertEqual(error as? ValidationError, .tagNameRequired)
        }

        let longName = String(repeating: "a", count: 31)
        XCTAssertThrowsError(try Tag.validate(
            name: longName,
            color: "#FF6B6B"
        )) { error in
            XCTAssertEqual(error as? ValidationError, .tagNameTooLong)
        }
    }

    func testColorValidation() {
        XCTAssertThrowsError(try Tag.validate(
            name: "私",
            color: "FF6B6B"
        )) { error in
            XCTAssertEqual(error as? ValidationError, .tagColorInvalidFormat)
        }

        XCTAssertThrowsError(try Tag.validate(
            name: "私",
            color: "#FF6B6"
        )) { error in
            XCTAssertEqual(error as? ValidationError, .tagColorInvalidFormat)
        }

        XCTAssertThrowsError(try Tag.validate(
            name: "私",
            color: "#FF6B6BB"
        )) { error in
            XCTAssertEqual(error as? ValidationError, .tagColorInvalidFormat)
        }

        XCTAssertThrowsError(try Tag.validate(
            name: "私",
            color: "#GG6B6B"
        )) { error in
            XCTAssertEqual(error as? ValidationError, .tagColorInvalidFormat)
        }
    }

    func testUpdate() {
        let tag = Tag(name: "テスト", color: "#FF6B6B")
        let originalUpdatedAt = tag.updatedAt

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
        XCTAssertEqual(tag.color, originalColor)
    }

    func testDefaultTags() {
        XCTAssertFalse(Tag.defaultTags.isEmpty)
        XCTAssertGreaterThanOrEqual(Tag.defaultTags.count, 4)

        for (name, color) in Tag.defaultTags {
            XCTAssertFalse(name.isEmpty)
            XCTAssertTrue(Tag.validateColor(color))
        }

        let tagNames = Tag.defaultTags.map { $0.name }
        XCTAssertTrue(tagNames.contains("私"))
        XCTAssertTrue(tagNames.contains("家族"))
        XCTAssertTrue(tagNames.contains("仕事"))
        XCTAssertTrue(tagNames.contains("貯金"))
    }

    func testValidationPerformance() {
        measure {
            for _ in 0..<1_000 {
                try? Tag.validate(name: "テスト", color: "#FF6B6B")
            }
        }
    }
}

// MARK: - Color

final class TagColorTests: XCTestCase {

    func testValidateColor() {
        XCTAssertTrue(Tag.validateColor("#FF6B6B"))
        XCTAssertTrue(Tag.validateColor("#000000"))
        XCTAssertTrue(Tag.validateColor("#FFFFFF"))
        XCTAssertTrue(Tag.validateColor("#123ABC"))

        XCTAssertFalse(Tag.validateColor("FF6B6B"))
        XCTAssertFalse(Tag.validateColor("#FF6B6"))
        XCTAssertFalse(Tag.validateColor("#FF6B6BB"))
        XCTAssertFalse(Tag.validateColor("#GG6B6B"))
        XCTAssertFalse(Tag.validateColor(""))
        XCTAssertFalse(Tag.validateColor("#"))
    }

    func testSwiftUIColor() {
        let tag = Tag(name: "テスト", color: "#FF6B6B")
        XCTAssertNotNil(tag.swiftUIColor)
    }

    func testSortOrderDefaultsToZero() {
        let tag = Tag(name: "デフォルト", color: "#123456")
        XCTAssertEqual(tag.sortOrder, 0)
    }

    func testSortOrderInitialization() {
        let tag = Tag(name: "位置", color: "#654321", sortOrder: 5)
        XCTAssertEqual(tag.sortOrder, 5)
    }

    func testColorHexInitializer() {
        let validTag = Tag(name: "テスト", color: "#FF6B6B")
        XCTAssertNotNil(validTag.swiftUIColor)

        let invalidTag = Tag(name: "テスト", color: "#INVALID")
        XCTAssertNotNil(invalidTag.swiftUIColor)
    }

    func testColorValidationPerformance() {
        measure {
            for _ in 0..<1_000 {
                _ = Tag.validateColor("#FF6B6B")
            }
        }
    }
}

// MARK: - Relationships

@MainActor
final class TagRelationshipTests: XCTestCase {

    func testTagCanBeAssignedToMultipleAccounts() throws {
        let (container, context) = try makeInMemoryStack()
        _ = container

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

        try context.save()

        XCTAssertTrue(accountA.tags.contains { $0.id == tag.id })
        XCTAssertTrue(accountB.tags.contains { $0.id == tag.id })
        XCTAssertEqual(tag.accounts.count, 2)
        XCTAssertTrue(tag.accounts.contains { $0.id == accountA.id })
        XCTAssertTrue(tag.accounts.contains { $0.id == accountB.id })
    }

    func testRemovingTagDoesNotAffectOtherAccounts() throws {
        let (container, context) = try makeInMemoryStack()
        _ = container

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
        try context.save()

        accountA.removeTag(tag, in: context)
        try context.save()

        XCTAssertFalse(accountA.tags.contains { $0.id == tag.id })
        XCTAssertTrue(accountB.tags.contains { $0.id == tag.id })
        XCTAssertEqual(tag.accounts.count, 1)
        XCTAssertTrue(tag.accounts.contains { $0.id == accountB.id })
    }

    func testSequentialAssignmentKeepsTagOnAllAccounts() throws {
        let (container, context) = try makeInMemoryStack()
        _ = container

        let sharedTag = Tag(name: "共用", color: "#FF6B6B")
        context.insert(sharedTag)

        let accounts = createSequentialAccounts(in: context)
        try assignSharedTagSequentially(accounts: accounts, sharedTag: sharedTag, context: context)
        try assertSharedTagPersistence(tag: sharedTag, context: context)
    }

    func testTagPersistsAcrossMultipleAccountsInModelContext() throws {
        let (container, context) = try makeInMemoryStack()
        _ = container

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
        let descriptor = FetchDescriptor<Tag>(
            predicate: #Predicate { $0.id == tagID }
        )
        guard let persistedTag = try context.fetch(descriptor).first else {
            XCTFail("タグが保存されていません")
            return
        }

        XCTAssertEqual(persistedTag.accounts.count, 2)
        XCTAssertTrue(persistedTag.accounts.contains { $0.id == accountA.id })
        XCTAssertTrue(persistedTag.accounts.contains { $0.id == accountB.id })
    }

    private func makeInMemoryStack() throws -> (ModelContainer, ModelContext) {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: BankAccount.self,
            Tag.self,
            AccountTagAssignment.self,
            configurations: configuration
        )
        return (container, container.mainContext)
    }

    private func createSequentialAccounts(in context: ModelContext) -> [BankAccount] {
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
        return accounts
    }

    private func assignSharedTagSequentially(
        accounts: [BankAccount],
        sharedTag: Tag,
        context: ModelContext
    ) throws {
        var assignedAccounts: [BankAccount] = []

        for account in accounts {
            account.updateTags([sharedTag], in: context)
            assignedAccounts.append(account)

            let expectedIDs = Set(assignedAccounts.map(\.id))
            let currentIDs = Set(sharedTag.accounts.map(\.id))
            XCTAssertEqual(currentIDs, expectedIDs)

            try context.save()

            let savedIDs = Set(sharedTag.accounts.map(\.id))
            XCTAssertEqual(savedIDs, expectedIDs)

            try assertTagPersistence(for: account, sharedTag: sharedTag, context: context)
        }

        for account in accounts {
            XCTAssertTrue(account.tags.contains { $0.id == sharedTag.id })
        }
    }

    private func assertSharedTagPersistence(tag: Tag, context: ModelContext) throws {
        let accounts = try context.fetch(FetchDescriptor<BankAccount>())
        XCTAssertEqual(accounts.count, 3)
        for account in accounts {
            XCTAssertTrue(account.tags.contains { $0.id == tag.id })
        }

        let tagID = tag.id
        let descriptor = FetchDescriptor<Tag>(predicate: #Predicate { $0.id == tagID })
        guard let persistedTag = try context.fetch(descriptor).first else {
            XCTFail("タグが保存されていません")
            return
        }

        XCTAssertEqual(persistedTag.accounts.count, accounts.count)
        for account in accounts {
            XCTAssertTrue(persistedTag.accounts.contains { $0.id == account.id })
        }
    }

    private func assertTagPersistence(
        for account: BankAccount,
        sharedTag: Tag,
        context: ModelContext
    ) throws {
        let accountID = account.id
        let descriptor = FetchDescriptor<BankAccount>(
            predicate: #Predicate { $0.id == accountID }
        )
        guard let reloadedAccount = try context.fetch(descriptor).first else {
            XCTFail("口座がフェッチできません: \(account.bankName)")
            return
        }

        XCTAssertTrue(reloadedAccount.tags.contains { $0.id == sharedTag.id })
    }
}
