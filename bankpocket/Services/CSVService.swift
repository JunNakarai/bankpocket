//
//  CSVService.swift
//  bankpocket
//
//  Created by Jun Nakarai on 2025/09/19.
//

import Foundation
import SwiftData
import UniformTypeIdentifiers

@MainActor
class CSVService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Export

    func exportAccountsToCSV() throws -> URL {
        let fetchDescriptor = FetchDescriptor<BankAccount>()
        let accounts = try modelContext.fetch(fetchDescriptor)

        var csvContent = "銀行名,支店名,支店番号,口座番号,タグ,作成日,更新日\n"

        for account in accounts {
            let tagNames = account.tags.map { $0.name }.joined(separator: ";")
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

            let row = [
                escapeCSVField(account.bankName),
                escapeCSVField(account.branchName),
                escapeCSVField(account.branchNumber),
                escapeCSVField(account.accountNumber),
                escapeCSVField(tagNames),
                escapeCSVField(dateFormatter.string(from: account.createdAt)),
                escapeCSVField(dateFormatter.string(from: account.updatedAt))
            ].joined(separator: ",")

            csvContent += row + "\n"
        }

        return try saveCSVToTempFile(content: csvContent, filename: "口座一覧.csv")
    }

    // MARK: - Import

    func importAccountsFromCSV(url: URL) throws -> ImportResult {
        guard url.startAccessingSecurityScopedResource() else {
            throw CSVError.fileAccessDenied
        }
        defer { url.stopAccessingSecurityScopedResource() }

        let csvContent = try String(contentsOf: url, encoding: .utf8)
        let lines = csvContent.components(separatedBy: .newlines)

        guard lines.count > 1 else {
            throw CSVError.invalidFormat
        }

        // Skip header line
        let dataLines = Array(lines.dropFirst()).filter { !$0.isEmpty }
        var successCount = 0
        var errorCount = 0
        var errors: [String] = []

        // Get existing tags for mapping
        let fetchDescriptor = FetchDescriptor<Tag>()
        let existingTags = try modelContext.fetch(fetchDescriptor)
        let tagDict = Dictionary(uniqueKeysWithValues: existingTags.map { ($0.name, $0) })

        for (index, line) in dataLines.enumerated() {
            do {
                let fields = parseCSVLine(line)

                guard fields.count >= 4 else {
                    throw CSVError.invalidRowFormat
                }

                let bankName = fields[0].trimmingCharacters(in: .whitespacesAndNewlines)
                let branchName = fields.count > 1 ? fields[1].trimmingCharacters(in: .whitespacesAndNewlines) : ""
                let branchNumber = fields.count > 2 ? fields[2].trimmingCharacters(in: .whitespacesAndNewlines) : ""
                let accountNumber = fields.count > 3 ? fields[3].trimmingCharacters(in: .whitespacesAndNewlines) : ""
                let tagNames = fields.count > 4 ? fields[4].trimmingCharacters(in: .whitespacesAndNewlines) : ""

                // Validate
                try BankAccount.validate(
                    bankName: bankName,
                    branchName: branchName,
                    branchNumber: branchNumber,
                    accountNumber: accountNumber
                )

                // Check for duplicates
                let existingAccounts = try modelContext.fetch(FetchDescriptor<BankAccount>())
                let isDuplicate = existingAccounts.contains { existing in
                    existing.bankName == bankName &&
                    existing.branchNumber == branchNumber &&
                    existing.accountNumber == accountNumber &&
                    !branchNumber.isEmpty && !accountNumber.isEmpty
                }

                if isDuplicate {
                    errors.append("行\(index + 2): 重複する口座です")
                    errorCount += 1
                    continue
                }

                // Get next sort order
                let allAccounts = try modelContext.fetch(FetchDescriptor<BankAccount>())
                let maxOrder = allAccounts.map(\.sortOrder).max() ?? -1

                // Create account
                let account = BankAccount(
                    bankName: bankName,
                    branchName: branchName,
                    branchNumber: branchNumber,
                    accountNumber: accountNumber,
                    sortOrder: maxOrder + successCount + 1
                )

                // Add tags
                if !tagNames.isEmpty {
                    let tagList = tagNames.components(separatedBy: ";")
                    for tagName in tagList {
                        let trimmedName = tagName.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !trimmedName.isEmpty, let tag = tagDict[trimmedName] {
                            account.addTag(tag, in: modelContext)
                        }
                    }
                }

                modelContext.insert(account)
                successCount += 1

            } catch {
                errors.append("行\(index + 2): \(error.localizedDescription)")
                errorCount += 1
            }
        }

        if successCount > 0 {
            try modelContext.save()
        }

        return ImportResult(
            successCount: successCount,
            errorCount: errorCount,
            errors: errors
        )
    }

    // MARK: - Helper Methods

    private func escapeCSVField(_ field: String) -> String {
        if field.contains(",") || field.contains("\"") || field.contains("\n") {
            return "\"" + field.replacingOccurrences(of: "\"", with: "\"\"") + "\""
        }
        return field
    }

    private func parseCSVLine(_ line: String) -> [String] {
        var fields: [String] = []
        var currentField = ""
        var insideQuotes = false
        var i = line.startIndex

        while i < line.endIndex {
            let char = line[i]

            if char == "\"" {
                if insideQuotes {
                    let nextIndex = line.index(after: i)
                    if nextIndex < line.endIndex && line[nextIndex] == "\"" {
                        // Escaped quote
                        currentField += "\""
                        i = line.index(after: nextIndex)
                        continue
                    } else {
                        // End quote
                        insideQuotes = false
                    }
                } else {
                    // Start quote
                    insideQuotes = true
                }
            } else if char == "," && !insideQuotes {
                fields.append(currentField)
                currentField = ""
            } else {
                currentField += String(char)
            }

            i = line.index(after: i)
        }

        fields.append(currentField)
        return fields
    }

    private func saveCSVToTempFile(content: String, filename: String) throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(filename)

        try content.write(to: fileURL, atomically: true, encoding: .utf8)
        return fileURL
    }
}

// MARK: - Supporting Types

struct ImportResult {
    let successCount: Int
    let errorCount: Int
    let errors: [String]

    var hasErrors: Bool {
        errorCount > 0
    }

    var summary: String {
        if errorCount == 0 {
            return "\(successCount)件の口座をインポートしました"
        } else {
            return "\(successCount)件成功、\(errorCount)件失敗"
        }
    }
}

enum CSVError: Error, LocalizedError {
    case fileAccessDenied
    case invalidFormat
    case invalidRowFormat
    case writeError

    var errorDescription: String? {
        switch self {
        case .fileAccessDenied:
            return "ファイルにアクセスできません"
        case .invalidFormat:
            return "CSVファイルの形式が正しくありません"
        case .invalidRowFormat:
            return "行の形式が正しくありません"
        case .writeError:
            return "ファイルの書き込みに失敗しました"
        }
    }
}
