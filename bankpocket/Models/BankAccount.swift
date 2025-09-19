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

    var tags: [Tag]

    init(
        bankName: String,
        branchName: String,
        branchNumber: String,
        accountNumber: String
    ) {
        self.id = UUID()
        self.bankName = bankName
        self.branchName = branchName
        self.branchNumber = branchNumber
        self.accountNumber = accountNumber
        self.createdAt = Date()
        self.updatedAt = Date()
        self.tags = []
    }

    // MARK: - Computed Properties

    var displayAccountNumber: String {
        return accountNumber
    }

    var fullDisplayName: String {
        return "\(bankName) \(branchName) (\(branchNumber))"
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

    func addTag(_ tag: Tag) {
        if !tags.contains(tag) {
            tags.append(tag)
        }
    }

    func removeTag(_ tag: Tag) {
        tags.removeAll { $0.id == tag.id }
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