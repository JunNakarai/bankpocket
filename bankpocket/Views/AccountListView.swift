//
//  AccountListView.swift
//  bankpocket
//
//  Created by Jun Nakarai on 2025/09/19.
//

import SwiftUI
import SwiftData

struct AccountListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \BankAccount.sortOrder, order: .forward) private var accounts: [BankAccount]
    @Query private var tags: [Tag]

    @Binding var showingAddAccount: Bool
    @Binding var showingImportExport: Bool

    @State private var searchText = ""
    @State private var selectedTag: Tag?
    @State private var showingAccountDetail = false
    @State private var selectedAccount: BankAccount?
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingFileImporter = false
    @State private var showingShareSheet = false
    @State private var exportFileURL: URL?
    @State private var importResult: ImportResult?
    @State private var showingImportResult = false

    var body: some View {
        VStack {
            // Search and Filter Section
            searchAndFilterSection

            // Account List
            if filteredAccounts.isEmpty {
                emptyStateView
            } else {
                accountListSection
            }
        }
        .sheet(isPresented: $showingAddAccount) {
            AccountFormView(account: nil)
        }
        .sheet(item: $selectedAccount) { account in
            AccountFormView(account: account)
        }
        .alert("エラー", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .confirmationDialog("インポート・エクスポート", isPresented: $showingImportExport) {
            Button("CSVエクスポート") {
                exportToCSV()
            }
            Button("CSVインポート") {
                showingFileImporter = true
            }
            Button("キャンセル", role: .cancel) { }
        } message: {
            Text("口座データをCSVファイルで管理できます")
        }
        .fileImporter(
            isPresented: $showingFileImporter,
            allowedContentTypes: [.commaSeparatedText, .plainText],
            allowsMultipleSelection: false
        ) { result in
            handleFileImport(result)
        }
        .sheet(isPresented: $showingShareSheet) {
            if let url = exportFileURL {
                ShareSheet(activityItems: [url])
            }
        }
        .alert("インポート結果", isPresented: $showingImportResult) {
            Button("OK") { }
        } message: {
            if let result = importResult {
                Text(result.summary + (result.hasErrors ? "\n\nエラー:\n" + result.errors.joined(separator: "\n") : ""))
            }
        }
    }

    // MARK: - View Components

    private var searchAndFilterSection: some View {
        VStack(spacing: 12) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("銀行名または支店名で検索", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                if !searchText.isEmpty {
                    Button("クリア") {
                        searchText = ""
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }

            // Tag Filter
            if !tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        Button("すべて") {
                            selectedTag = nil
                        }
                        .buttonStyle(FilterButtonStyle(isSelected: selectedTag == nil))

                        ForEach(tags, id: \.id) { tag in
                            Button(tag.name) {
                                selectedTag = selectedTag?.id == tag.id ? nil : tag
                            }
                            .buttonStyle(FilterButtonStyle(
                                isSelected: selectedTag?.id == tag.id,
                                color: tag.swiftUIColor
                            ))
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding()
    }

    private var accountListSection: some View {
        List {
            ForEach(filteredAccounts, id: \.id) { account in
                AccountRowView(account: account) {
                    selectedAccount = account
                    showingAccountDetail = true
                }
                .swipeActions(edge: .trailing) {
                    Button("削除", role: .destructive) {
                        deleteAccount(account)
                    }
                }
            }
            .onMove(perform: moveAccounts)
        }
        .listStyle(PlainListStyle())
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "creditcard")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("口座が登録されていません")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("右上の + ボタンから\n最初の口座を追加してください")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button("口座を追加") {
                showingAddAccount = true
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Computed Properties

    private var filteredAccounts: [BankAccount] {
        var filtered = accounts

        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { account in
                account.bankName.localizedCaseInsensitiveContains(searchText) ||
                account.branchName.localizedCaseInsensitiveContains(searchText) ||
                account.branchNumber.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Apply tag filter
        if let selectedTag = selectedTag {
            filtered = filtered.filter { account in
                account.tags.contains { $0.id == selectedTag.id }
            }
        }

        // Sort by sortOrder, then by bank name for items with same order
        return filtered.sorted {
            if $0.sortOrder == $1.sortOrder {
                return $0.bankName < $1.bankName
            }
            return $0.sortOrder < $1.sortOrder
        }
    }

    // MARK: - Actions

    private func deleteAccount(_ account: BankAccount) {
        withAnimation {
            modelContext.delete(account)
            try? modelContext.save()
        }
    }

    // MARK: - Import/Export Actions

    private func exportToCSV() {
        do {
            let csvService = CSVService(modelContext: modelContext)
            let fileURL = try csvService.exportAccountsToCSV()
            exportFileURL = fileURL
            showingShareSheet = true
        } catch {
            errorMessage = "エクスポートに失敗しました: \(error.localizedDescription)"
            showingError = true
        }
    }

    private func handleFileImport(_ result: Result<[URL], Error>) {
        do {
            let fileURLs = try result.get()
            guard let fileURL = fileURLs.first else { return }

            let csvService = CSVService(modelContext: modelContext)
            importResult = try csvService.importAccountsFromCSV(url: fileURL)
            showingImportResult = true
        } catch {
            errorMessage = "インポートに失敗しました: \(error.localizedDescription)"
            showingError = true
        }
    }

    // MARK: - Reorder Actions

    private func moveAccounts(from source: IndexSet, to destination: Int) {
        // Only allow reordering when no filters are applied
        guard searchText.isEmpty && selectedTag == nil else { return }

        var reorderedAccounts = filteredAccounts
        reorderedAccounts.move(fromOffsets: source, toOffset: destination)

        // Update sort order for all affected accounts
        for (index, account) in reorderedAccounts.enumerated() {
            account.sortOrder = index
        }

        do {
            try modelContext.save()
        } catch {
            errorMessage = "順序の保存に失敗しました: \(error.localizedDescription)"
            showingError = true
        }
    }
}

// MARK: - Account Row View

struct AccountRowView: View {
    let account: BankAccount
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(account.bankName)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text("\(account.branchName) (\(account.branchNumber))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text("口座番号: \(account.displayAccountNumber)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    // Tags
                    if !account.tags.isEmpty {
                        HStack {
                            ForEach(account.tags.prefix(2), id: \.id) { tag in
                                Text(tag.name)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(tag.swiftUIColor.opacity(0.2))
                                    .foregroundColor(tag.swiftUIColor)
                                    .cornerRadius(4)
                            }

                            if account.tags.count > 2 {
                                Text("+\(account.tags.count - 2)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Filter Button Style

struct FilterButtonStyle: ButtonStyle {
    let isSelected: Bool
    let color: Color?

    init(isSelected: Bool, color: Color? = nil) {
        self.isSelected = isSelected
        self.color = color
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                isSelected
                    ? (color ?? .blue)
                    : Color.gray.opacity(0.2)
            )
            .foregroundColor(
                isSelected
                    ? .white
                    : .primary
            )
            .cornerRadius(16)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    AccountListView(
        showingAddAccount: .constant(false),
        showingImportExport: .constant(false)
    )
.modelContainer(for: [BankAccount.self, Tag.self, AccountTagAssignment.self], inMemory: true)
}
