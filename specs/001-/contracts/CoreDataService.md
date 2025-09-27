# SwiftDataService 契約

**サービス名**: SwiftDataService  
**役割**: SwiftData の `ModelContainer` を初期化し、`ModelContext` に対する保存処理やバックグラウンド実行を提供する

> 旧仕様では Core Data を利用していたが、本プロジェクトでは SwiftData を採用する。以下は SwiftData 前提の契約内容である。

## インターフェース定義

### プロトコル（例）

<!-- markdownlint-disable MD013 -->

```swift
protocol SwiftDataServiceProtocol {
    var container: ModelContainer { get }
    var mainContext: ModelContext { get }

    func save(_ context: ModelContext?) throws
    func performBackgroundTask<T>(_ operation: @escaping (ModelContext) throws -> T) async throws -> T
    func reset(store: ModelContainer? ) throws
}
```

<!-- markdownlint-enable MD013 -->

## モデルコンテナ構成

- **対象モデル**: `BankAccount`, `Tag`, `AccountTagAssignment`
- **ストア形式**: `.sqlite`
- **配置場所**: アプリの Application Support ディレクトリ
- **マイグレーション**: ライトウェイトマイグレーション有効
- **永続ストア設定**: WAL モードを有効化し書き込み性能を確保
- **データ保全**: 起動時に sortOrder の欠損や重複がないか確認し補正

## オペレーション

### save

#### save: 入力

- `ModelContext?`（省略時は `mainContext`）

#### save: 出力

- なし

#### save: ビジネスルール

- `context.hasChanges` が `true` のときのみ保存
- 失敗時はエラーメッセージをローカライズして上位へ伝搬
- 保存成功後は必要に応じて `context.reset()` でキャッシュをクリア

#### save: エラー

- `SwiftDataError.saveFailed(underlying: Error)`

### performBackgroundTask

#### performBackgroundTask: 入力

- `ModelContext` を受け取る非同期クロージャ

#### performBackgroundTask: 出力

- クロージャの戻り値

#### performBackgroundTask: ビジネスルール

- バックグラウンド用 `ModelContext` を生成してクロージャに渡す
- 処理中に例外が発生した場合は保存を行わずに再スロー
- クロージャ内で `save()` を呼ぶか、サービス側で検知して保存する

#### performBackgroundTask: エラー

- `SwiftDataError.backgroundTaskFailed(underlying: Error)`

### reset

#### reset: 入力

- 任意の `ModelContainer`（省略時は既定のコンテナ）

#### reset: 出力

- なし

#### reset: ビジネスルール

- テストなどで利用するリセット操作。ストアファイルを削除し新たに初期化
- 実運用では多用しないため、明示的に呼び出す場面を制限する

#### reset: エラー

- `SwiftDataError.resetFailed`

## エラー定義

```swift
enum SwiftDataError: Error, LocalizedError {
    case saveFailed(underlying: Error)
    case backgroundTaskFailed(underlying: Error)
    case resetFailed
    case containerInitializationFailed

    var errorDescription: String? {
        switch self {
        case .saveFailed(let error):
            return "データの保存に失敗しました: \(error.localizedDescription)"
        case .backgroundTaskFailed(let error):
            return "バックグラウンド処理に失敗しました: \(error.localizedDescription)"
        case .resetFailed:
            return "データベースのリセットに失敗しました"
        case .containerInitializationFailed:
            return "モデルコンテナの初期化に失敗しました"
        }
    }
}
```

## テスト契約

### 単体テスト

1. `testSaveWhenContextHasChanges` — 変更がある場合に保存が行われる
2. `testSaveWithoutChanges` — 変更がない場合は保存が呼ばれない
3. `testSaveFailurePropagatesError` — 保存失敗時に `saveFailed` を返す
4. `testPerformBackgroundTaskSuccess` — バックグラウンド処理の結果が戻る
5. `testPerformBackgroundTaskFailure` — 例外が `backgroundTaskFailed` として伝搬
6. `testResetRemovesStore` — リセット後にストアが再作成される

### 統合テスト

- コンテナを初期化し、`BankAccount` と `Tag` の CRUD が一貫して実行できるか確認
- 並行アクセス時にデータ破損が発生しないことを検証
