//
//  TagFormView.swift
//  bankpocket
//
//  Created by Jun Nakarai on 2025/09/19.
//

import SwiftUI
import SwiftData

struct TagFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var existingTags: [Tag]

    let tag: Tag?

    @State private var tagName = ""
    @State private var tagColor = "#FF6B6B"
    @State private var showingColorPicker = false
    @State private var showingError = false
    @State private var errorMessage = ""

    let predefinedColors = [
        "#FF6B6B", "#4ECDC4", "#45B7D1", "#96CEB4",
        "#FECA57", "#FF9FF3", "#54A0FF", "#5F27CD",
        "#00D2D3", "#FF9F43", "#1DD1A1", "#FD79A8"
    ]

    var isEditing: Bool { tag != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("タグ名", text: $tagName)
                        .textContentType(.none)
                } header: {
                    Text("タグ情報")
                } footer: {
                    Text("タグ名は30文字以内で入力してください")
                }

                Section {
                    // Current Color Preview
                    HStack {
                        Text("選択中の色")
                        Spacer()
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(hex: tagColor) ?? .gray)
                            .frame(width: 40, height: 20)
                        Text(tagColor.uppercased())
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    // Predefined Colors
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                        ForEach(predefinedColors, id: \.self) { color in
                            Button {
                                tagColor = color
                            } label: {
                                Circle()
                                    .fill(Color(hex: color) ?? .gray)
                                    .frame(width: 30, height: 30)
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                tagColor == color ? Color.primary : Color.clear,
                                                lineWidth: 2
                                            )
                                    )
                            }
                        }
                    }
                    .padding(.vertical, 8)

                    // Custom Color Input
                    HStack {
                        TextField("カスタム色コード", text: $tagColor)
                            .textContentType(.none)
                            .autocapitalization(.allCharacters)

                        Button("ランダム") {
                            tagColor = predefinedColors.randomElement() ?? "#FF6B6B"
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                } header: {
                    Text("色選択")
                } footer: {
                    Text("#RRGGBB形式で入力してください（例: #FF6B6B）")
                }
            }
            .navigationTitle(isEditing ? "タグ編集" : "タグ作成")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveTag()
                    }
                    .disabled(!isValidForm)
                }
            }
            .alert("エラー", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                loadTagData()
            }
        }
    }

    // MARK: - Computed Properties

    private var isValidForm: Bool {
        !tagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        Tag.validateColor(tagColor)
    }

    // MARK: - Actions

    private func loadTagData() {
        if let tag = tag {
            tagName = tag.name
            tagColor = tag.color
        }
    }

    private func saveTag() {
        do {
            let trimmedName = tagName.trimmingCharacters(in: .whitespacesAndNewlines)

            // Validate input
            try Tag.validate(name: trimmedName, color: tagColor)

            // Check for duplicates (if not editing the same tag)
            let duplicateExists = existingTags.contains { existingTag in
                guard existingTag.id != tag?.id else { return false }
                return existingTag.name.lowercased() == trimmedName.lowercased()
            }

            if duplicateExists {
                throw ValidationError.duplicateTag
            }

            if let tag = tag {
                // Update existing tag
                tag.update(name: trimmedName, color: tagColor)
            } else {
                // Create new tag
                let newTag = Tag(name: trimmedName, color: tagColor)
                modelContext.insert(newTag)
            }

            try modelContext.save()
            dismiss()

        } catch let error as ValidationError {
            errorMessage = error.localizedDescription
            showingError = true
        } catch {
            errorMessage = "保存に失敗しました: \(error.localizedDescription)"
            showingError = true
        }
    }
}

#Preview {
    TagFormView(tag: nil)
        .modelContainer(for: [BankAccount.self, Tag.self], inMemory: true)
}