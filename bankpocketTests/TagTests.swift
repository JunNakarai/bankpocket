//
//  TagTests.swift
//  bankpocketTests
//
//  Created by Jun Nakarai on 2025/09/19.
//

import XCTest
import SwiftUI
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

    // MARK: - Color Extension Tests

    func testColorHexInitializer() {
        // Test through Tag's swiftUIColor property which uses Color(hex:)
        let validTag = Tag(name: "テスト", color: "#FF6B6B")
        XCTAssertNotNil(validTag.swiftUIColor)

        let invalidTag = Tag(name: "テスト", color: "#INVALID")
        // Even invalid colors should return a fallback color (blue)
        XCTAssertNotNil(invalidTag.swiftUIColor)
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