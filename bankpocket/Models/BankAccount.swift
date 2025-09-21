//
//  BankAccount.swift
//  bankpocket
//
//  Created by Jun Nakarai on 2025/09/18.
//

import Foundation
import SwiftData

@Model
final class BankAccount {
    @Attribute(.unique) var id: UUID
    var bankName: String
    var branchName: String
    var branchNumber: String
    var accountNumber: String
    var createdAt: Date
    var updatedAt: Date
    var sortOrder: Int

    var tagAssignments: [AccountTagAssignment]

    init(
        bankName: String,
        branchName: String,
        branchNumber: String,
        accountNumber: String,
        sortOrder: Int = 0
    ) {
        self.id = UUID()
        self.bankName = bankName
        self.branchName = branchName
        self.branchNumber = branchNumber
        self.accountNumber = accountNumber
        self.createdAt = Date()
        self.updatedAt = Date()
        self.sortOrder = sortOrder
        self.tagAssignments = []
    }

    // MARK: - Computed Properties

    var displayAccountNumber: String {
        return accountNumber
    }

    var fullDisplayName: String {
        return "\(bankName) \(branchName) (\(branchNumber))"
    }

    var tags: [Tag] {
        tagAssignments.map(\.tag)
    }

    // MARK: - Update Method

    func update(
        bankName: String? = nil,
        branchName: String? = nil,
        branchNumber: String? = nil,
        accountNumber: String? = nil
    ) {
        if let bankName = bankName { self.bankName = bankName }
        if let branchName = branchName { self.branchName = branchName }
        if let branchNumber = branchNumber { self.branchNumber = branchNumber }
        if let accountNumber = accountNumber { self.accountNumber = accountNumber }
        self.updatedAt = Date()
    }

    // MARK: - Tag Management

    func addTag(_ tag: Tag, in context: ModelContext) {
        guard !tagAssignments.contains(where: { $0.tag.id == tag.id }) else { return }
        let assignment = AccountTagAssignment(account: self, tag: tag)
        context.insert(assignment)
    }

    func removeTag(_ tag: Tag, in context: ModelContext) {
        let assignmentsToRemove = tagAssignments.filter { $0.tag.id == tag.id }
        for assignment in assignmentsToRemove {
            assignment.tag.tagAssignments.removeAll { $0.id == assignment.id }
            context.delete(assignment)
        }
        tagAssignments.removeAll { $0.tag.id == tag.id }
    }

    func updateTags(_ newTags: [Tag], in context: ModelContext) {
        let desiredTagIDs = Set(newTags.map(\.id))

        let assignmentsToRemove = tagAssignments.filter { !desiredTagIDs.contains($0.tag.id) }
        for assignment in assignmentsToRemove {
            assignment.tag.tagAssignments.removeAll { $0.id == assignment.id }
            context.delete(assignment)
        }
        tagAssignments.removeAll { assignment in
            !desiredTagIDs.contains(assignment.tag.id)
        }

        for tag in newTags where !tagAssignments.contains(where: { $0.tag.id == tag.id }) {
            let assignment = AccountTagAssignment(account: self, tag: tag)
            context.insert(assignment)
        }
    }

    // MARK: - Validation

    static func validate(
        bankName: String,
        branchName: String = "",
        branchNumber: String = "",
        accountNumber: String = ""
    ) throws {
        // Bank name validation (required)
        let trimmedBankName = bankName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedBankName.isEmpty else {
            throw ValidationError.bankNameRequired
        }
        guard trimmedBankName.count <= 50 else {
            throw ValidationError.bankNameTooLong
        }

        // Branch name validation (optional)
        let trimmedBranchName = branchName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedBranchName.isEmpty {
            guard trimmedBranchName.count <= 50 else {
                throw ValidationError.branchNameTooLong
            }
        }

        // Branch number validation (optional)
        let trimmedBranchNumber = branchNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedBranchNumber.isEmpty {
            guard NSPredicate(format: "SELF MATCHES %@", "^[0-9]{3}$").evaluate(with: trimmedBranchNumber) else {
                throw ValidationError.branchNumberInvalidFormat
            }
            guard let branchNum = Int(trimmedBranchNumber), branchNum >= 1 && branchNum <= 999 else {
                throw ValidationError.branchNumberRange
            }
        }

        // Account number validation (optional)
        let trimmedAccountNumber = accountNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedAccountNumber.isEmpty {
            guard NSPredicate(format: "SELF MATCHES %@", "^[0-9]{7}$").evaluate(with: trimmedAccountNumber) else {
                throw ValidationError.accountNumberInvalidFormat
            }
        }
    }
}
