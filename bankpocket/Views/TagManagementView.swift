//
//  TagManagementView.swift
//  bankpocket
//
//  Created by Jun Nakarai on 2025/09/19.
//

import SwiftUI
import SwiftData

struct TagManagementView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tags: [Tag]
    @Query private var accounts: [BankAccount]

    @State private var searchText = ""
    @State private var showingAddTag = false
    @State private var showingTagForm = false
    @State private var selectedTag: Tag?
    @State private var showingDeleteAlert = false
    @State private var tagToDelete: Tag?
    @State private var showingError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            VStack {
                if tags.isEmpty {
                    emptyStateView
                } else {
                    VStack {
                        // Statistics Section
                        statisticsSection

                        // Search Section
                        searchSection

                        // Tag List
                        tagListSection
                    }
                }
            }
            .navigationTitle("タグ管理")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Menu {
                        Button("デフォルトタグを作成") {
                            createDefaultTags()
                        }

                        Button("未使用タグを削除", role: .destructive) {
                            deleteUnusedTags()
                        }
                        .disabled(unusedTags.isEmpty)
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }

                    Button {
                        selectedTag = nil
                        showingTagForm = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingTagForm) {
                TagFormView(tag: selectedTag)
            }
            .alert("タグを削除", isPresented: $showingDeleteAlert) {
                Button("削除", role: .destructive) {
                    if let tag = tagToDelete {
                        deleteTag(tag)
                    }
                }
                Button("キャンセル", role: .cancel) { }
            } message: {
                if let tag = tagToDelete {
                    Text("「\(tag.name)」を削除してもよろしいですか？\n\(tag.accountCount)個の口座から削除されます。")
                }
            }
            .alert("エラー", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }

    // MARK: - View Components

    private var statisticsSection: some View {
        HStack(spacing: 16) {
            StatisticCard(
                title: "総タグ数",
                value: "\(tags.count)",
                icon: "tag",
                color: .blue
            )

            StatisticCard(
                title: "使用中",
                value: "\(usedTags.count)",
                icon: "tag.fill",
                color: .green
            )

            StatisticCard(
                title: "未使用",
                value: "\(unusedTags.count)",
                icon: "tag",
                color: .orange
            )
        }
        .padding()
    }

    private var searchSection: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField("タグ名で検索", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if !searchText.isEmpty {
                Button("クリア") {
                    searchText = ""
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
        }
        .padding(.horizontal)
    }

    private var tagListSection: some View {
        List {
            ForEach(filteredTags, id: \.id) { tag in
                TagRowView(tag: tag, accountCount: tag.accountCount) {
                    selectedTag = tag
                    showingTagForm = true
                }
                .swipeActions(edge: .trailing) {
                    Button("削除", role: .destructive) {
                        tagToDelete = tag
                        showingDeleteAlert = true
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "tag")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("タグが作成されていません")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("右上の + ボタンから\n最初のタグを作成してください")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            VStack(spacing: 12) {
                Button("タグを作成") {
                    selectedTag = nil
                    showingTagForm = true
                }
                .buttonStyle(.borderedProminent)

                Button("デフォルトタグを作成") {
                    createDefaultTags()
                }
                .buttonStyle(.bordered)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Computed Properties

    private var filteredTags: [Tag] {
        let filtered = searchText.isEmpty ? tags : tags.filter { tag in
            tag.name.localizedCaseInsensitiveContains(searchText)
        }
        return filtered.sorted { $0.name < $1.name }
    }

    private var usedTags: [Tag] {
        tags.filter { !$0.accounts.isEmpty }
    }

    private var unusedTags: [Tag] {
        tags.filter { $0.accounts.isEmpty }
    }

    // MARK: - Actions

    private func createDefaultTags() {
        do {
            for (name, color) in Tag.defaultTags {
                // Check if tag already exists
                let exists = tags.contains { $0.name == name }
                if !exists {
                    let tag = Tag(name: name, color: color)
                    modelContext.insert(tag)
                }
            }
            try modelContext.save()
        } catch {
            errorMessage = "デフォルトタグの作成に失敗しました: \(error.localizedDescription)"
            showingError = true
        }
    }

    private func deleteUnusedTags() {
        do {
            for tag in unusedTags {
                modelContext.delete(tag)
            }
            try modelContext.save()
        } catch {
            errorMessage = "未使用タグの削除に失敗しました: \(error.localizedDescription)"
            showingError = true
        }
    }

    private func deleteTag(_ tag: Tag) {
        withAnimation {
            modelContext.delete(tag)
            try? modelContext.save()
        }
    }
}

// MARK: - Tag Row View

struct TagRowView: View {
    let tag: Tag
    let accountCount: Int
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Circle()
                    .fill(tag.swiftUIColor)
                    .frame(width: 20, height: 20)

                VStack(alignment: .leading, spacing: 2) {
                    Text(tag.name)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text("\(accountCount)個の口座で使用中")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(tag.color.uppercased())
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Statistic Card

struct StatisticCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    TagManagementView()
        .modelContainer(for: [BankAccount.self, Tag.self, AccountTagAssignment.self], inMemory: true)
}
