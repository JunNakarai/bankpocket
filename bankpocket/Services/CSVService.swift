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
        let dataLines = try loadCSVDataLines(from: url)
        let tagLookup = try fetchExistingTags()
        var existingAccounts = try modelContext.fetch(FetchDescriptor<BankAccount>())
        var nextSortOrder = (existingAccounts.map(\.sortOrder).max() ?? -1) + 1

        var accumulator = ImportAccumulator()

        for (index, line) in dataLines.enumerated() {
            do {
                let parsedLine = try parseAccountFields(from: line)
                try validateDuplicateAccount(parsedLine, within: existingAccounts)
                try BankAccount.validate(
                    bankName: parsedLine.bankName,
                    branchName: parsedLine.branchName,
                    branchNumber: parsedLine.branchNumber,
                    accountNumber: parsedLine.accountNumber
                )

                let account = BankAccount(
                    bankName: parsedLine.bankName,
                    branchName: parsedLine.branchName,
                    branchNumber: parsedLine.branchNumber,
                    accountNumber: parsedLine.accountNumber,
                    sortOrder: nextSortOrder
                )

                assignTags(parsedLine.tags, to: account, using: tagLookup)

                modelContext.insert(account)
                existingAccounts.append(account)
                nextSortOrder += 1
                accumulator.recordSuccess()
            } catch {
                accumulator.recordError(
                    "行\(index + 2): \(error.localizedDescription)"
                )
            }
        }

        if accumulator.successCount > 0 {
            try modelContext.save()
        }

        return accumulator.buildResult()
    }

    // MARK: - Helper Methods

    private func loadCSVDataLines(from url: URL) throws -> [String] {
        guard url.startAccessingSecurityScopedResource() else {
            throw CSVError.fileAccessDenied
        }
        defer { url.stopAccessingSecurityScopedResource() }

        let csvContent = try String(contentsOf: url, encoding: .utf8)
        let lines = csvContent.components(separatedBy: .newlines)

        guard lines.count > 1 else {
            throw CSVError.invalidFormat
        }

        return Array(lines.dropFirst()).filter { !$0.isEmpty }
    }

    private func fetchExistingTags() throws -> [String: Tag] {
        let descriptor = FetchDescriptor<Tag>()
        let tags = try modelContext.fetch(descriptor)
        return Dictionary(uniqueKeysWithValues: tags.map { ($0.name, $0) })
    }

    private func parseAccountFields(from line: String) throws -> CSVAccountFields {
        let fields = parseCSVLine(line)

        guard fields.count >= 4 else {
            throw CSVError.invalidRowFormat
        }

        let bankName = fields[0].trimmingCharacters(in: .whitespacesAndNewlines)
        let branchName = fields.count > 1 ? fields[1].trimmingCharacters(in: .whitespacesAndNewlines) : ""
        let branchNumber = fields.count > 2 ? fields[2].trimmingCharacters(in: .whitespacesAndNewlines) : ""
        let accountNumber = fields.count > 3 ? fields[3].trimmingCharacters(in: .whitespacesAndNewlines) : ""
        let tagField = fields.count > 4 ? fields[4] : ""

        let tagNames = tagField
            .components(separatedBy: ";")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        return CSVAccountFields(
            bankName: bankName,
            branchName: branchName,
            branchNumber: branchNumber,
            accountNumber: accountNumber,
            tags: tagNames
        )
    }

    private func validateDuplicateAccount(_ data: CSVAccountFields, within accounts: [BankAccount]) throws {
        guard !data.branchNumber.isEmpty, !data.accountNumber.isEmpty else { return }

        let exists = accounts.contains { account in
            account.bankName == data.bankName &&
            account.branchNumber == data.branchNumber &&
            account.accountNumber == data.accountNumber
        }

        if exists {
            throw CSVError.duplicateAccount
        }
    }

    private func assignTags(_ names: [String], to account: BankAccount, using lookup: [String: Tag]) {
        for name in names {
            if let tag = lookup[name] {
                account.addTag(tag, in: modelContext)
            }
        }
    }

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
        var index = line.startIndex

        while index < line.endIndex {
            let character = line[index]

            if character == "\"" {
                if insideQuotes {
                    let nextIndex = line.index(after: index)
                    if nextIndex < line.endIndex && line[nextIndex] == "\"" {
                        // Escaped quote
                        currentField += "\""
                        index = line.index(after: nextIndex)
                        continue
                    } else {
                        // End quote
                        insideQuotes = false
                    }
                } else {
                    // Start quote
                    insideQuotes = true
                }
            } else if character == "," && !insideQuotes {
                fields.append(currentField)
                currentField = ""
            } else {
                currentField += String(character)
            }

            index = line.index(after: index)
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

private struct CSVAccountFields {
    let bankName: String
    let branchName: String
    let branchNumber: String
    let accountNumber: String
    let tags: [String]
}

private struct ImportAccumulator {
    private(set) var successCount = 0
    private(set) var errors: [String] = []

    mutating func recordSuccess() {
        successCount += 1
    }

    mutating func recordError(_ message: String) {
        errors.append(message)
    }

    func buildResult() -> ImportResult {
        ImportResult(
            successCount: successCount,
            errorCount: errors.count,
            errors: errors
        )
    }
}

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
    case duplicateAccount

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
        case .duplicateAccount:
            return "重複する口座です"
        }
    }
}
