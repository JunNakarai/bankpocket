//
//  ContentView.swift
//  bankpocket
//
//  Created by Jun Nakarai on 2025/09/18.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var showingTagManagement = false
    @State private var showingAddAccount = false
    @State private var showingImportExport = false
    @State private var searchText = ""
    @State private var isSearchActive = false
    @FocusState private var searchFieldFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                AccountListView(
                    showingAddAccount: $showingAddAccount,
                    showingImportExport: $showingImportExport,
                    searchText: $searchText
                )
                .toolbar { toolbarContent }
                .safeAreaInset(edge: .top, alignment: .center, spacing: 0) {
                    if isSearchActive {
                        searchOverlay
                            .padding(.horizontal, 16)
                            .padding(.top, 12)
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .animation(.spring(response: 0.35, dampingFraction: 0.78), value: isSearchActive)
                    }
                }

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        addAccountButton
                    }
                }
            }
            .sheet(isPresented: $showingTagManagement) {
                NavigationStack {
                    TagManagementView()
                        .navigationTitle("タグ管理")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("完了") {
                                    showingTagManagement = false
                                }
                            }
                        }
                }
            }
        }
    }
}

private extension ContentView {
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        if !isSearchActive {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    activateSearch()
                } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.title3)
                }
                .accessibilityLabel("検索")
                .accessibilityHint("検索バーを表示")

                Button {
                    showingTagManagement = true
                } label: {
                    Image(systemName: "tag.circle")
                        .font(.title3)
                }
                .accessibilityLabel("タグ管理")
                .accessibilityHint("タップしてタグ管理画面を開く")

                Button {
                    showingImportExport = true
                } label: {
                    Image(systemName: "arrow.up.arrow.down.circle")
                        .font(.title3)
                }
                .accessibilityLabel("インポート・エクスポート")
                .accessibilityHint("CSVファイルのインポート・エクスポート")
            }
        }
    }

    @ViewBuilder
    var floatingAddButtonBackground: some View {
        if #available(iOS 26, *) {
            GlassEffectContainer(spacing: 0) {
                Circle()
                    .fill(.clear)
                    .glassEffect(
                        .regular
                            .tint(Color.accentColor.opacity(0.35))
                            .interactive(true),
                        in: Circle()
                    )
            }
        } else {
            Circle()
                .fill(Color.accentColor)
        }
    }

    private var addAccountButton: some View {
        Button {
            showingAddAccount = true
        } label: {
            ZStack {
                floatingAddButtonBackground

                if #available(iOS 26, *) {
                    Image(systemName: "plus")
                        .font(.title2.weight(.medium))
                        .foregroundStyle(.primary)
                } else {
                    Image(systemName: "plus")
                        .font(.title2.weight(.medium))
                        .foregroundColor(.white)
                }
            }
            .frame(width: 56, height: 56)
            .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)
        }
        .accessibilityLabel("口座追加")
        .accessibilityHint("タップして新しい口座を追加")
        .padding(.trailing, 20)
        .padding(.bottom, 34)
    }

    @ViewBuilder
    private var searchBarBackground: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(Color(.systemGray6))
    }

    private var searchOverlay: some View {
        VStack(spacing: 8) {
            ZStack {
                if #available(iOS 26, *) {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.clear)
                        .glassEffect(
                            .regular
                                .tint(Color.accentColor.opacity(0.2))
                                .interactive(true),
                            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
                        )
                } else {
                    searchBarBackground
                        .shadow(color: .black.opacity(0.12), radius: 6, x: 0, y: 3)
                }

                searchBarContent
            }
            .frame(height: 46)

            if searchText.isEmpty {
                Text("銀行名・支店名・支店番号で検索できます")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 4)
            }
        }
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(.clear)
    }

    private var searchBarContent: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.body.weight(.medium))
                .foregroundColor(.secondary)

            TextField("銀行名または支店名で検索", text: $searchText)
                .textFieldStyle(.plain)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .submitLabel(.search)
                .focused($searchFieldFocused)

            Button {
                if searchText.isEmpty {
                    dismissSearch()
                } else {
                    searchText = ""
                }
            } label: {
                Image(systemName: searchText.isEmpty ? "xmark.circle" : "xmark.circle.fill")
                    .foregroundStyle(.secondary.opacity(0.7))
            }
            .accessibilityLabel(searchText.isEmpty ? "検索を閉じる" : "検索キーワードをクリア")
        }
        .padding(.horizontal, 18)
        .frame(maxWidth: .infinity, minHeight: 46, alignment: .leading)
    }

    private func activateSearch() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
            isSearchActive = true
        }
        DispatchQueue.main.async {
            searchFieldFocused = true
        }
    }

    private func dismissSearch() {
        searchFieldFocused = false
        withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
            isSearchActive = false
        }
        searchText = ""
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [BankAccount.self, Tag.self, AccountTagAssignment.self], inMemory: true)
}
