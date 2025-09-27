# TagService 契約

**サービス名**: TagService  
**役割**: タグの CRUD と口座との関連付けを管理する

## インターフェース定義

### プロトコル

<!-- markdownlint-disable MD013 -->

```swift
protocol TagServiceProtocol {
    func createTag(name: String, color: String) async throws -> Tag
    func getAllTags() async throws -> [Tag]
    func getTag(by id: UUID) async throws -> Tag?
    func getTag(by name: String) async throws -> Tag?
    func updateTag(_ tag: Tag, name: String?, color: String?) async throws -> Tag
    func deleteTag(_ tag: Tag) async throws
    func addTag(_ tag: Tag, to account: BankAccount) async throws
    func removeTag(_ tag: Tag, from account: BankAccount) async throws
    func suggestedTags() -> [(name: String, color: String)]
}
```

<!-- markdownlint-enable MD013 -->

## オペレーション

### createTag

#### createTag: 入力

- `name`: 必須、30 文字以内（大文字小文字を無視してユニーク）
- `color`: 必須、`#RRGGBB` 形式

#### createTag: 出力

- 作成した `Tag`

#### createTag: ビジネスルール

- 空文字や重複名は許可しない
- カラーコードの形式を検証する
- `sortOrder` は既存の最大値 + 1 を割り当てる

#### createTag: エラー

- `TagError.duplicateName`
- `TagError.invalidInput(field:)`
- `TagError.persistenceError`

### getAllTags

#### getAllTags: 入力

- なし

#### getAllTags: 出力

- `Tag` 配列（`sortOrder` 昇順 → `createdAt` 昇順）

#### getAllTags: ビジネスルール

- 空の場合は空配列
- 各 `Tag` に `accountCount` を算出できるようリレーションを含めて取得

### getTag(by: UUID)

#### getTag(by UUID): 入力

- `UUID`

#### getTag(by UUID): 出力

- `Tag?`

#### getTag(by UUID): ビジネスルール

- 該当しない ID の場合は `nil`
- リレーションを含めて返す

### getTag(by: String)

#### getTag(by name): 入力

- タグ名

#### getTag(by name): 出力

- `Tag?`

#### getTag(by name): ビジネスルール

- 大文字小文字を無視して一致させる
- 見つからない場合は `nil`

### updateTag

#### updateTag: 入力

- `tag`: 既存タグ
- `name` / `color`: 任意更新

#### updateTag: 出力

- 更新後の `Tag`

#### updateTag: ビジネスルール

- `nil` のフィールドは変更しない
- 新しい名前が既存タグと重複したら `duplicateName`
- カラーコードは常に検証する
- 更新後は `updatedAt` と `sortOrder` を必要に応じて調整

#### updateTag: エラー

- `TagError.tagNotFound`
- `TagError.duplicateName`
- `TagError.invalidInput(field:)`
- `TagError.persistenceError`

### deleteTag

#### deleteTag: 入力

- `Tag`

#### deleteTag: 出力

- なし

#### deleteTag: ビジネスルール

- 関連する口座との割り当てを解除してから削除
- 既に割り当てがある場合でも削除可能だが確認ダイアログで警告

#### deleteTag: エラー

- `TagError.tagNotFound`
- `TagError.persistenceError`

### addTag / removeTag

#### addTag/removeTag: 入力

- `Tag`
- `BankAccount`

#### addTag/removeTag: 出力

- なし

#### addTag/removeTag: ビジネスルール

- 多対多の割り当てを追加/削除する
- 既に割り当て済みの場合は重複して追加しない
- 割り当てが存在しない場合の削除は no-op

#### addTag/removeTag: エラー

- `TagError.tagNotFound`
- `TagError.accountNotFound`
- `TagError.persistenceError`

### suggestedTags

#### suggestedTags: 入力

- なし

#### suggestedTags: 出力

- 推奨タグの配列（名前とカラーコード）

#### suggestedTags: ビジネスルール

- アプリ初回起動時などに UI が提示する初期候補
- 実際のタグレコードは別途生成する

## エラー定義

```swift
enum TagError: Error, LocalizedError {
    case duplicateName
    case tagNotFound
    case accountNotFound
    case invalidInput(field: String)
    case persistenceError

    var errorDescription: String? {
        switch self {
        case .duplicateName:
            return "同じ名前のタグが既に存在します"
        case .tagNotFound:
            return "タグが見つかりません"
        case .accountNotFound:
            return "指定した口座が見つかりません"
        case .invalidInput(let field):
            return "\(field)の入力が無効です"
        case .persistenceError:
            return "データ保存処理でエラーが発生しました"
        }
    }
}
```

## テスト契約

### 単体テスト

1. `testCreateTagSuccess` — 正常系でタグが作成される
2. `testCreateTagDuplicate` — 重複名で `duplicateName` を投げる
3. `testCreateTagInvalidColor` — カラーコード不正で `invalidInput`
4. `testGetAllTagsSorted` — 並び順が `sortOrder` を維持する
5. `testUpdateTagName` — 名前変更時もユニーク制約が守られる
6. `testDeleteTagRemovesAssignments` — 割り当ても解除される
7. `testAddTagToAccount` — 重複なく割り当てが作成される
8. `testRemoveTagFromAccount` — 割り当てのみ削除される

### 統合テスト

- タグの作成 → 口座へ割り当て → フィルター表示の一連の流れが動作する
- 並び替え操作が `sortOrder` に保存され、他画面にも反映される
