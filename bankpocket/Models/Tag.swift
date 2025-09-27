//
//  Tag.swift
//  bankpocket
//
//  Created by Jun Nakarai on 2025/09/18.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class Tag {
    @Attribute(.unique) var id: UUID
    var name: String
    var color: String
    var createdAt: Date
    var updatedAt: Date
    var sortOrder: Int

    var tagAssignments: [AccountTagAssignment]

    init(name: String, color: String, sortOrder: Int = 0) {
        self.id = UUID()
        self.name = name
        self.color = color
        self.createdAt = Date()
        self.updatedAt = Date()
        self.sortOrder = sortOrder
        self.tagAssignments = []
    }

    // MARK: - Computed Properties

    var swiftUIColor: Color {
        return Color(hex: color) ?? .blue
    }

    var accounts: [BankAccount] {
        tagAssignments.map(\.account)
    }

    var accountCount: Int {
        return tagAssignments.count
    }

    var isUsed: Bool {
        return !tagAssignments.isEmpty
    }

    // MARK: - Update Method

    func update(name: String? = nil, color: String? = nil) {
        if let name = name { self.name = name }
        if let color = color { self.color = color }
        self.updatedAt = Date()
    }

    // MARK: - Default Tags

    static let defaultTags: [(name: String, color: String)] = [
        ("私", "#FF6B6B"),
        ("家族", "#4ECDC4"),
        ("仕事", "#45B7D1"),
        ("貯金", "#96CEB4"),
        ("投資", "#FECA57"),
        ("緊急時", "#FF9FF3")
    ]

    // MARK: - Color Validation

    static func validateColor(_ color: String) -> Bool {
        let trimmedColor = color.trimmingCharacters(in: .whitespacesAndNewlines)
        return NSPredicate(format: "SELF MATCHES %@", "^#[0-9A-Fa-f]{6}$").evaluate(with: trimmedColor)
    }

    // MARK: - Validation

    static func validate(name: String, color: String) throws {
        // Name validation
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            throw ValidationError.tagNameRequired
        }
        guard trimmedName.count <= 30 else {
            throw ValidationError.tagNameTooLong
        }

        // Color validation
        guard validateColor(color) else {
            throw ValidationError.tagColorInvalidFormat
        }
    }
}

// MARK: - Color Extension

extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
