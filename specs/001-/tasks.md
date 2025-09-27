# タスク一覧: 銀行口座管理アプリ

<!-- markdownlint-disable MD013 -->

**入力**: `/specs/001-/` 内の設計資料  
**参照必須**: `plan.md`（必須）、`data-model.md`、`quickstart.md`、`contracts/`

## 実行フロー（/tasks コマンド相当）

```text
1. feature ディレクトリ直下の plan.md を読み取る
   → 見つからなければ "No implementation plan found" で停止
   → 技術スタック・ライブラリ・構成方針を抽出
2. 任意ドキュメントを順に読み込む
   → data-model.md: エンティティを読み取りモデルタスクへ展開
   → contracts/: 各契約書から契約テストタスクを生成
   → quickstart.md: 受け入れシナリオを統合テストへ反映
3. カテゴリ別にタスクを生成
   → Setup / Tests / Core / Integration / Polish
4. タスクルールを適用
   → 異なるファイルを扱うタスクは [P] で並行可と明示
   → 同一ファイルを扱うタスクはシーケンシャル（[P] なし）
   → テストは実装より先に配置（TDD）
5. T001 から連番で採番
6. 依存関係グラフを構築
7. 並列実行のサンプルを提示
8. 完全性チェック
   → 各契約にテストが紐付いているか
   → 各エンティティにモデルタスクが存在するか
   → 主要受け入れ条件を満たす統合テストがあるか
9. 成果物を返却（タスク準備完了）
```

## 表記ルール

- 形式: `[ID] [P] 説明`
- `[P]` は並列実行可能な場合のみ付与
- 説明内に必ずファイルパスを明記（`bankpocket/...`）

## パス規約

- アプリ本体: `bankpocket/`
- 単体テスト: `bankpocketTests/`
- UI テスト: `bankpocketUITests/`

## フェーズ 3.1: セットアップ

- [ ] T001 プロジェクトのフォルダ構成確認と必要な空ディレクトリの作成 (`bankpocket/`, `bankpocketTests/`)
- [ ] T002 SwiftLint など開発ツールの設定ファイル整理（必要に応じて共有設定を定義）
- [ ] T003 [P] Git フックや CI 設定の下書き（導入する場合は `scripts/` に配置）

## フェーズ 3.2: 先にテストを書く（TDD 必須）

重要: すべての実装タスクより前に失敗するテストを追加すること

### サービス契約テスト

- [ ] T004 CoreData ベースの保存・取得の契約テストを `bankpocketTests/Services/CSVServiceTests.swift` に作成
- [ ] T005 口座サービスの契約テストを `bankpocketTests/Services/AccountServiceTests.swift` に作成
- [ ] T006 タグサービスの契約テストを `bankpocketTests/Services/TagServiceTests.swift` に作成

### モデルテスト

- [ ] T007 [P] `BankAccount` のバリデーション/リレーションテストを `bankpocketTests/Models/BankAccountTests.swift` に追加
- [ ] T008 [P] `Tag` のバリデーション/リレーションテストを `bankpocketTests/Models/TagTests.swift` に追加

### 統合テスト

- [ ] T009 口座登録〜一覧反映の統合テストを `bankpocketTests/Integration/AccountRegistrationTests.swift` に追加
- [ ] T010 タグ割り当てとフィルタリングの統合テストを `bankpocketTests/Integration/TagFilterTests.swift` に追加
- [ ] T011 検索機能の統合テストを `bankpocketTests/Integration/AccountSearchTests.swift` に追加
- [ ] T012 データ永続性（アプリ再起動相当）の統合テストを `bankpocketTests/Integration/DataPersistenceTests.swift` に追加

## フェーズ 3.3: コア実装（テストが失敗している状態で着手）

### SwiftData モデル

- [ ] T013 [P] `bankpocket/Models/BankAccount.swift` に口座モデルとバリデーション実装
- [ ] T014 [P] `bankpocket/Models/Tag.swift` にタグモデルとバリデーション実装
- [ ] T015 `bankpocket/Models/AccountTagAssignment.swift` のリレーション管理と整合性処理
- [ ] T016 SwiftData スキーマ全体の整備（`BankPocketApp.swift` 起動時のマイグレーション含む）

### サービス層

- [ ] T017 [P] CSV 入出力サービスを `bankpocket/Services/CSVService.swift` に実装
- [ ] T018 口座操作のビジネスロジックを `bankpocket/Services/AccountService.swift` に実装（T013, T015 依存）
- [ ] T019 タグ操作のビジネスロジックを `bankpocket/Services/TagService.swift` に実装（T014, T015 依存）

### ViewModel（必要に応じて）

- [ ] T020 [P] 一覧表示用ロジックを `bankpocket/ViewModels/AccountListViewModel.swift` に実装（サービス依存）
- [ ] T021 [P] 口座フォーム用ロジックを `bankpocket/ViewModels/AccountFormViewModel.swift` に実装
- [ ] T022 [P] タグ管理ロジックを `bankpocket/ViewModels/TagManagementViewModel.swift` に実装

### SwiftUI ビュー

- [ ] T023 [P] `bankpocket/Views/AccountListView.swift` を一覧 + フィルター機能込みで実装
- [ ] T024 [P] `bankpocket/Views/AccountFormView.swift` を実装し、検証とタグ割当 UI を追加
- [ ] T025 [P] `bankpocket/Views/TagManagementView.swift` を実装し、タグ作成/編集/削除を提供
- [ ] T026 [P] 再利用コンポーネント（タグチップ、統計カードなど）を `bankpocket/Views/Components/` に分離

### エラー定義

- [ ] T027 [P] 共通バリデーションエラーを `bankpocket/Models/ValidationError.swift` に整理
- [ ] T028 [P] CSV インポート時のエラー種別を `bankpocket/Services/CSVImportError.swift` に定義

## フェーズ 3.4: 連携

- [ ] T029 アプリエントリ `bankpocket/bankpocketApp.swift` で ModelContainer 初期化と DI を確立
- [ ] T030 ルートビュー `bankpocket/ContentView.swift` のナビゲーションを調整
- [ ] T031 View→Service の依存解決（`@Environment(\.modelContext)` 或いは DI) を統一
- [ ] T032 多言語対応とエラーメッセージのローカライズ確認
- [ ] T033 検索・フィルター・並び替えの状態同期を仕上げる

## フェーズ 3.5: 仕上げ

- [ ] T034 [P] バリデーションとサービスロジックの単体テスト補完
- [ ] T035 [P] ViewModel テスト（モック化したサービスを使用）
- [ ] T036 パフォーマンステスト（CoreData 操作 < 100ms 目標）
- [ ] T037 アクセシビリティ対応（VoiceOver、Dynamic Type）
- [ ] T038 メモリ使用量最適化チェック（50MB 未満）
- [ ] T039 `quickstart.md` のシナリオを使った手動検証の実施記録
- [ ] T040 SwiftLint など静的解析を通し、修正コミット

## 依存関係概要

- セットアップ (T001-T003) → すべてのタスクの前提
- テスト (T004-T012) → 実装 (T013以降) の前
- モデル (T013-T016) → サービス (T017-T019)
- サービス → ViewModel → ビュー
- エラー定義 → サービス/ビューが利用
- 連携フェーズ → すべてのコア実装が揃ってから
- 仕上げフェーズ → 最終確認

## 並列実行例

```text
# サービス契約テスト群（T004-T006）を並行
# モデルテスト群（T007-T008）も並行実行可能
# SwiftData モデル（T013-T015）は異なるファイルに分かれるため並列可
# ViewModel 実装（T020-T022）は依存完了後に並行で進められる
```

## 注意事項

- [P] タスクは本当に依存がない場合のみ使用
- テストは必ず先に失敗させてから実装
- 1 タスク完了ごとにコミットを推奨
- UI 文言は全て日本語で統一
- 60fps と 50MB 未満という性能目標を常に意識

## バリデーションチェック

- [x] 各契約に対応するテストが存在
- [x] 各エンティティにモデルタスクが存在
- [x] テストが実装より先に配置されている
- [x] 並列指定のタスクはファイルが衝突しない
- [x] 各タスクに明確なファイルパスが記載されている
