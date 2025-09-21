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

    var body: some View {
        NavigationStack {
            ZStack {
                AccountListView(
                    showingAddAccount: $showingAddAccount,
                    showingImportExport: $showingImportExport
                )
                    .toolbar {
                        ToolbarItemGroup(placement: .navigationBarTrailing) {
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

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            showingAddAccount = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(Color.blue)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .accessibilityLabel("口座追加")
                        .accessibilityHint("タップして新しい口座を追加")
                        .padding(.trailing, 20)
                        .padding(.bottom, 34)
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

#Preview {
    ContentView()
        .modelContainer(for: [BankAccount.self, Tag.self, AccountTagAssignment.self], inMemory: true)
}
