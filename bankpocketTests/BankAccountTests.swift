//
//  BankAccountTests.swift
//  bankpocketTests
//
//  Created by Jun Nakarai on 2025/09/19.
//

import XCTest
@testable import bankpocket

final class BankAccountTests: XCTestCase {

    // MARK: - Validation Tests

    func testValidAccountValidation() {
        // Only bank name required
        XCTAssertNoThrow(try BankAccount.validate(
            bankName: "みずほ銀行"
        ))

        // All fields provided
        XCTAssertNoThrow(try BankAccount.validate(
            bankName: "みずほ銀行",
            branchName: "渋谷支店",
            branchNumber: "123",
            accountNumber: "1234567"
        ))
    }

    func testBankNameValidation() {
        // Empty bank name
        XCTAssertThrowsError(try BankAccount.validate(
            bankName: "",
            branchName: "渋谷支店",
            branchNumber: "123",
            accountNumber: "1234567"
        )) { error in
            XCTAssertEqual(error as? ValidationError, .bankNameRequired)
        }

        // Too long bank name
        let longName = String(repeating: "a", count: 51)
        XCTAssertThrowsError(try BankAccount.validate(
            bankName: longName,
            branchName: "渋谷支店",
            branchNumber: "123",
            accountNumber: "1234567"
        )) { error in
            XCTAssertEqual(error as? ValidationError, .bankNameTooLong)
        }
    }

    func testBranchNameValidation() {
        // Empty branch name is now allowed
        XCTAssertNoThrow(try BankAccount.validate(
            bankName: "みずほ銀行",
            branchName: ""
        ))

        // Too long branch name
        let longName = String(repeating: "a", count: 51)
        XCTAssertThrowsError(try BankAccount.validate(
            bankName: "みずほ銀行",
            branchName: longName
        )) { error in
            XCTAssertEqual(error as? ValidationError, .branchNameTooLong)
        }
    }

    func testBranchNumberValidation() {
        // Empty branch number is now allowed
        XCTAssertNoThrow(try BankAccount.validate(
            bankName: "みずほ銀行",
            branchNumber: ""
        ))

        // Invalid format - too short (when provided)
        XCTAssertThrowsError(try BankAccount.validate(
            bankName: "みずほ銀行",
            branchNumber: "12"
        )) { error in
            XCTAssertEqual(error as? ValidationError, .branchNumberInvalidFormat)
        }

        // Invalid format - too long (when provided)
        XCTAssertThrowsError(try BankAccount.validate(
            bankName: "みずほ銀行",
            branchNumber: "1234"
        )) { error in
            XCTAssertEqual(error as? ValidationError, .branchNumberInvalidFormat)
        }

        // Invalid format - contains letters (when provided)
        XCTAssertThrowsError(try BankAccount.validate(
            bankName: "みずほ銀行",
            branchNumber: "12a"
        )) { error in
            XCTAssertEqual(error as? ValidationError, .branchNumberInvalidFormat)
        }

        // Out of range (when provided)
        XCTAssertThrowsError(try BankAccount.validate(
            bankName: "みずほ銀行",
            branchNumber: "000"
        )) { error in
            XCTAssertEqual(error as? ValidationError, .branchNumberRange)
        }
    }

    func testAccountNumberValidation() {
        // Empty account number is now allowed
        XCTAssertNoThrow(try BankAccount.validate(
            bankName: "みずほ銀行",
            accountNumber: ""
        ))

        // Invalid format - too short (when provided)
        XCTAssertThrowsError(try BankAccount.validate(
            bankName: "みずほ銀行",
            accountNumber: "123456"
        )) { error in
            XCTAssertEqual(error as? ValidationError, .accountNumberInvalidFormat)
        }

        // Invalid format - too long (when provided)
        XCTAssertThrowsError(try BankAccount.validate(
            bankName: "みずほ銀行",
            accountNumber: "12345678"
        )) { error in
            XCTAssertEqual(error as? ValidationError, .accountNumberInvalidFormat)
        }

        // Invalid format - contains letters (when provided)
        XCTAssertThrowsError(try BankAccount.validate(
            bankName: "みずほ銀行",
            accountNumber: "123456a"
        )) { error in
            XCTAssertEqual(error as? ValidationError, .accountNumberInvalidFormat)
        }
    }

    // MARK: - Display Properties Tests

    func testDisplayAccountNumber() {
        let account = BankAccount(
            bankName: "みずほ銀行",
            branchName: "渋谷支店",
            branchNumber: "123",
            accountNumber: "1234567"
        )

        XCTAssertEqual(account.displayAccountNumber, "1234567")
    }

    func testFullDisplayName() {
        let account = BankAccount(
            bankName: "みずほ銀行",
            branchName: "渋谷支店",
            branchNumber: "123",
            accountNumber: "1234567"
        )

        XCTAssertEqual(account.fullDisplayName, "みずほ銀行 渋谷支店 (123)")
    }

    // MARK: - Update Tests

    func testUpdate() {
        let account = BankAccount(
            bankName: "みずほ銀行",
            branchName: "渋谷支店",
            branchNumber: "123",
            accountNumber: "1234567"
        )

        let originalUpdatedAt = account.updatedAt

        // Wait a bit to ensure different timestamp
        Thread.sleep(forTimeInterval: 0.01)

        account.update(
            bankName: "三菱UFJ銀行",
            branchName: "新宿支店"
        )

        XCTAssertEqual(account.bankName, "三菱UFJ銀行")
        XCTAssertEqual(account.branchName, "新宿支店")
        XCTAssertEqual(account.branchNumber, "123") // Unchanged
        XCTAssertEqual(account.accountNumber, "1234567") // Unchanged
        XCTAssertGreaterThan(account.updatedAt, originalUpdatedAt)
    }

    // MARK: - Performance Tests

    func testValidationPerformance() {
        measure {
            for _ in 0..<1000 {
                try? BankAccount.validate(
                    bankName: "みずほ銀行"
                )
            }
        }
    }
}