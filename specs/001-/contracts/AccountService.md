# AccountService 契約

**サービス名**: AccountService  
**役割**: 銀行口座の CRUD と関連ビジネスロジックを提供する

## インターフェース定義

### プロトコル

<!-- markdownlint-disable MD013 -->

```swift
protocol AccountServiceProtocol {
    func createAccount(bankName: String, branchName: String, branchNumber: String, accountNumber: String) async throws -> BankAccount
    func getAllAccounts() async throws -> [BankAccount]
    func getAccount(by id: UUID) async throws -> BankAccount?
    func updateAccount(_ account: BankAccount, bankName: String?, branchName: String?, branchNumber: String?, accountNumber: String?) async throws -> BankAccount
    func deleteAccount(_ account: BankAccount) async throws
    func searchAccounts(query: String) async throws -> [BankAccount]
    func getAccountsByTag(_ tag: Tag) async throws -> [BankAccount]
}
```

<!-- markdownlint-enable MD013 -->

## オペレーション詳細

### createAccount

#### createAccount: 入力

- `bankName`: 必須、50 文字以内
- `branchName`: 任意、50 文字以内
- `branchNumber`: 任意、3 桁の数字文字列
- `accountNumber`: 任意、7 桁の数字文字列

#### createAccount: 出力

- 作成された `BankAccount`

#### createAccount: ビジネスルール

- すべての文字列はトリムして検証する
- (`bankName`, `branchNumber`, `accountNumber`) が同一の口座は重複とみなす
- 重複時は `AccountError.duplicateAccount` を投げる
- バリデーションに失敗したフィールドは `AccountError.invalidInput(field:)`

### getAllAccounts

#### getAllAccounts: 入力

- なし

#### getAllAccounts: 出力

- `BankAccount` の配列（`sortOrder` 昇順 → `bankName` 昇順）

#### getAllAccounts: ビジネスルール

- 口座がない場合は空配列
- タグとの関連を含めて返す

### getAccount(by:)

#### getAccount(by:): 入力

- `UUID`

#### getAccount(by:): 出力

- 該当する `BankAccount`、存在しなければ `nil`

#### getAccount(by:): ビジネスルール

- 存在しない ID は `nil` を返す
- タグの関連情報も取得する

### updateAccount

#### updateAccount: 入力

- `account`: 更新対象
- `bankName` / `branchName` / `branchNumber` / `accountNumber`: それぞれ任意更新

#### updateAccount: 出力

- 更新後の `BankAccount`

#### updateAccount: ビジネスルール

- `nil` のフィールドは変更しない
- 更新後の値も作成時と同じバリデーションを適用
- 変更により別口座と重複する場合は `duplicateAccount`
- 更新成功時は `updatedAt` を再設定

### deleteAccount

#### deleteAccount: 入力

- `BankAccount`

#### deleteAccount: 出力

- なし

#### deleteAccount: ビジネスルール

- 関連する `AccountTagAssignment` をすべて削除
- ソフトデリートは不要（完全削除）

### searchAccounts

#### searchAccounts: 入力

- `query` 文字列

#### searchAccounts: 出力

- 条件に一致した `BankAccount` 配列

#### searchAccounts: ビジネスルール

- `bankName` / `branchName` / `branchNumber` / `accountNumber` を対象に部分一致検索
- 大文字小文字を区別しない
- 空文字列の場合は全件返す

### getAccountsByTag

#### getAccountsByTag: 入力

- `Tag`

#### getAccountsByTag: 出力

- 指定タグが付与された `BankAccount` 配列

#### getAccountsByTag: ビジネスルール

- タグに紐付く口座がなければ空配列
- 並び順は `getAllAccounts` と同一

## エラー定義

```swift
enum AccountError: Error, LocalizedError {
    case duplicateAccount
    case accountNotFound
    case invalidInput(field: String)
    case persistenceError

    var errorDescription: String? {
        switch self {
        case .duplicateAccount:
            return "同じ口座が既に登録されています"
        case .accountNotFound:
            return "口座が見つかりません"
        case .invalidInput(let field):
            return "\(field)の入力が無効です"
        case .persistenceError:
            return "データの保存に失敗しました"
        }
    }
}
```

## テスト契約

### 単体テスト

1. `testCreateAccountSuccess` — 正常入力で口座が作成される
2. `testCreateAccountDuplicate` — 重複入力で `duplicateAccount` を投げる
3. `testCreateAccountInvalidInput` — 不正入力で `invalidInput` を投げる
4. `testGetAllAccountsEmpty` — 口座がない場合は空配列
5. `testGetAllAccountsOrdered` — 並び順が `sortOrder` → `bankName` になる
6. `testGetAccountById` — 既存 ID を取得できる
7. `testUpdateAccount` — 更新が成功し `updatedAt` が変化する
8. `testDeleteAccount` — 割り当てごと削除される
9. `testSearchAccounts` — 部分一致検索が機能する
10. `testGetAccountsByTag` — タグでの取得が機能する

### 例外系検証

- 永続化層エラー発生時に `persistenceError` を上位へ伝播する
- 存在しない ID 更新・削除時に `accountNotFound` を返す
