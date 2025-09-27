# データモデル: 銀行口座管理アプリ

**日付**: 2025-09-18  
**対象機能**: 銀行口座管理（口座 + タグ）

## SwiftData スキーマ概要

### エンティティ

#### BankAccount

アプリの中核となる銀行口座データ。

##### BankAccount: 属性

- `id`: `UUID`（主キー、自動生成）
- `bankName`: `String`（必須、最大 50 文字、前後空白は除去）
- `branchName`: `String`（任意、最大 50 文字）
- `branchNumber`: `String`（任意、3 桁の数字文字列）
- `accountNumber`: `String`（任意、7 桁の数字文字列）
- `createdAt`: `Date`（作成日時、自動設定）
- `updatedAt`: `Date`（最終更新日時、自動更新）
- `sortOrder`: `Int`（一覧表示順、昇順で並ぶ）

##### BankAccount: リレーション

- `tagAssignments`: `AccountTagAssignment` との 1 対多（中間テーブル）
- 計算プロパティ `tags`: 関連タグを `sortOrder` → `name` の順に整列して返す

##### BankAccount: バリデーション

- `bankName`: 空文字禁止、50 文字以内
- `branchName`: 入力されていれば 50 文字以内
- `branchNumber`: 入力されていれば 正規表現 `^[0-9]{3}$` を満たすこと
- `accountNumber`: 入力されていれば 正規表現 `^[0-9]{7}$` を満たすこと
- 重複防止: (`bankName`, `branchNumber`, `accountNumber`) の組が既存口座と重ならない

#### Tag

口座を分類するためのタグ情報。

##### Tag: 属性

- `id`: `UUID`（主キー、自動生成）
- `name`: `String`（必須、ユニーク、30 文字以内）
- `color`: `String`（必須、`#RRGGBB` 形式）
- `createdAt`: `Date`（作成日時、自動設定）
- `updatedAt`: `Date`（最終更新日時、自動更新）
- `sortOrder`: `Int`（表示順、ドラッグ並び替えを反映）

##### Tag: リレーション

- `tagAssignments`: `AccountTagAssignment` との 1 対多
- 計算プロパティ `accounts`: 紐付く `BankAccount` の配列

##### Tag: バリデーション

- `name`: 空文字禁止、トリム後 30 文字以内、大文字小文字を無視してユニーク
- `color`: 正規表現 `^#[0-9A-Fa-f]{6}$` を満たす

#### AccountTagAssignment

BankAccount と Tag の多対多を表現する中間エンティティ。

##### AccountTagAssignment: 属性

- `id`: `UUID`（主キー、自動生成）
- `createdAt`: `Date`（割当日時、自動設定）

##### AccountTagAssignment: リレーション

- `account`: `BankAccount` への参照（必須）
- `tag`: `Tag` への参照（必須）

##### AccountTagAssignment: バリデーション / 挙動

- 1 口座に同一タグを重複割当しない
- 割当解除時は関連配列から双方向に削除する

## リレーション図

```text
BankAccount "1" <--> "*" AccountTagAssignment "*" <--> "1" Tag
```

- 1 口座に複数タグを付与できる
- 1 タグを複数口座に共有できる
- 中間エンティティが削除されると両側の配列から自動的に除外される

## ビジネスルール

### 口座管理

1. (`bankName`, `branchNumber`, `accountNumber`) が完全一致する口座は登録不可
2. 削除時は関連する `AccountTagAssignment` も合わせて削除
3. 編集時は `updatedAt` を更新し履歴を残す
4. 並び順は `sortOrder` を 0 から連番に保つ（ドラッグ操作時に更新）

### タグ管理

1. タグ名はユニーク（大文字小文字を無視）
2. タグ削除時は割当のみ解除し、口座自体は保持
3. デフォルトタグ候補（私/家族/仕事/貯金/投資/緊急時）を初回に投入
4. 並び順は `sortOrder` で管理し、長押し並び替えを反映

### データ整合性

1. SwiftData がリレーション整合性を維持（双方向で `tagAssignments` を同期）
2. すべての文字列入力は保存前にトリム
3. 例外発生時はユーザーに日本語メッセージを表示しリカバリ可能とする
4. モデル更新後は `modelContext.save()` を呼び、失敗時は適切にロールバック

## 永続化設定

- ストア: SQLite（アプリの `Application Support` 配下）
- マイグレーション: ライトウェイトマイグレーションを有効化
- コンテキスト: UI 用に `mainContext`、重い処理は必要に応じてバックグラウンド用を検討
- インデックス: `BankAccount.sortOrder`, `Tag.sortOrder` による並び順最適化

## 代表的なフェッチ要求

- 口座一覧: `BankAccount` を `sortOrder` 昇順 → 同値は `bankName` で昇順
- タグ一覧: `Tag` を `sortOrder` 昇順で取得
- タグフィルタ: `account.tags` に対象タグが含まれるかで絞り込み
- 検索: 銀行名、支店名、支店番号の部分一致（`localizedCaseInsensitiveContains`）

## テストデータ例

```text
口座1:
- 銀行: みずほ銀行
- 支店: 渋谷支店
- 支店番号: 123
- 口座番号: 1234567
- タグ: [私]

口座2:
- 銀行: 三菱UFJ銀行
- 支店: 新宿支店
- 支店番号: 456
- 口座番号: 9876543
- タグ: [家族, 貯金]
```

```text
タグ1: 私 (#FF6B6B)
タグ2: 家族 (#4ECDC4)
タグ3: 仕事 (#45B7D1)
タグ4: 貯金 (#96CEB4)
タグ5: 緊急時 (#FF9FF3)
```

**ステータス**: ✅ 完了 — データモデル仕様確定
