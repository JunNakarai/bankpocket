//
//  AccountFormView.swift
//  bankpocket
//
//  Created by Jun Nakarai on 2025/09/19.
//

import SwiftUI
import SwiftData

struct AccountFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var existingAccounts: [BankAccount]
    @Query(
        sort: [
            SortDescriptor(\Tag.sortOrder, order: .forward),
            SortDescriptor(\Tag.createdAt, order: .forward)
        ]
    ) private var tags: [Tag]

    let account: BankAccount?

    @State private var bankName = ""
    @State private var branchName = ""
    @State private var branchNumber = ""
    @State private var accountNumber = ""
    @State private var selectedTags: Set<Tag> = []

    @State private var showingError = false
    @State private var errorMessage = ""

    var isEditing: Bool { account != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("銀行名 *", text: $bankName)
                        .textContentType(.organizationName)

                    TextField("支店名（任意）", text: $branchName)
                        .textContentType(.organizationName)

                    TextField("支店番号（任意・3桁）", text: $branchNumber)
                        .textContentType(.none)
                        .keyboardType(.numberPad)
                        .onChange(of: branchNumber) { oldValue, newValue in
                            if newValue.count > 3 {
                                branchNumber = String(newValue.prefix(3))
                            }
                        }

                    TextField("口座番号（任意・7桁）", text: $accountNumber)
                        .textContentType(.none)
                        .keyboardType(.numberPad)
                        .onChange(of: accountNumber) { oldValue, newValue in
                            if newValue.count > 7 {
                                accountNumber = String(newValue.prefix(7))
                            }
                        }
                } header: {
                    Text("口座情報")
                } footer: {
                    Text("* 必須項目　支店番号は3桁、口座番号は7桁の数字で入力してください")
                }

                if !tags.isEmpty {
                    Section {
                        ForEach(tags, id: \.id) { tag in
                            Button {
                                toggleTag(tag)
                            } label: {
                                HStack {
                                    Circle()
                                        .fill(tag.swiftUIColor)
                                        .frame(width: 12, height: 12)

                                    Text(tag.name)
                                        .foregroundColor(.primary)

                                    Spacer()

                                    if selectedTags.contains(tag) {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    } header: {
                        Text("タグ")
                    } footer: {
                        Text("口座を分類するためのタグを選択してください")
                    }
                }
            }
            .navigationTitle(isEditing ? "口座編集" : "口座追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveAccount()
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
                loadAccountData()
            }
        }
    }

    // MARK: - Computed Properties

    private var isValidForm: Bool {
        !bankName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Actions

    private func loadAccountData() {
        if let account = account {
            bankName = account.bankName
            branchName = account.branchName
            branchNumber = account.branchNumber
            accountNumber = account.accountNumber
            selectedTags = Set(account.tags)
        }
    }

    private func toggleTag(_ tag: Tag) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            selectedTags.insert(tag)
        }
    }

    private func saveAccount() {
        do {
            // Validate input
            try BankAccount.validate(
                bankName: bankName,
                branchName: branchName,
                branchNumber: branchNumber,
                accountNumber: accountNumber
            )

            // Check for duplicates (if not editing the same account)
            let trimmedBankName = bankName.trimmingCharacters(in: .whitespacesAndNewlines)
            let trimmedBranchNumber = branchNumber.trimmingCharacters(in: .whitespacesAndNewlines)
            let trimmedAccountNumber = accountNumber.trimmingCharacters(in: .whitespacesAndNewlines)

            // Only check for duplicates if all fields are provided
            let duplicateExists = !trimmedBranchNumber.isEmpty && !trimmedAccountNumber.isEmpty &&
                existingAccounts.contains { existingAccount in
                    guard existingAccount.id != account?.id else { return false }
                    return existingAccount.bankName == trimmedBankName &&
                           existingAccount.branchNumber == trimmedBranchNumber &&
                           existingAccount.accountNumber == trimmedAccountNumber
                }

            if duplicateExists {
                throw ValidationError.duplicateAccount
            }

            if let account = account {
                // Update existing account
                account.update(
                    bankName: trimmedBankName,
                    branchName: branchName.trimmingCharacters(in: .whitespacesAndNewlines),
                    branchNumber: trimmedBranchNumber,
                    accountNumber: trimmedAccountNumber
                )

                // Update tags
                account.updateTags(Array(selectedTags), in: modelContext)
            } else {
                // Get next sort order
                let maxOrder = existingAccounts.map(\.sortOrder).max() ?? -1

                // Create new account
                let newAccount = BankAccount(
                    bankName: trimmedBankName,
                    branchName: branchName.trimmingCharacters(in: .whitespacesAndNewlines),
                    branchNumber: trimmedBranchNumber,
                    accountNumber: trimmedAccountNumber,
                    sortOrder: maxOrder + 1
                )

                modelContext.insert(newAccount)
                newAccount.updateTags(Array(selectedTags), in: modelContext)
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
    AccountFormView(account: nil)
        .modelContainer(for: [BankAccount.self, Tag.self, AccountTagAssignment.self], inMemory: true)
}
